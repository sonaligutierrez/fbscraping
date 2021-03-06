require "working_url"

ActiveAdmin.register PostCreator do
  menu label: proc { I18n.t("active_admin.post_creators") }, priority: 1
  permit_params :account_id, :fan_page, :url, :avatar, :fb_user, :fb_pass, :fb_session_id, :proxy_id, :cookie_info
  config.batch_actions = false
  config.filters = false

  index do
    render "admin/post_creators/index_post_creators", context: self
  end

  form do |f|
     f.inputs do
       f.input :account
       f.input :url
       f.input :fb_session_id, label: "fb_session", as: :select, collection: FbSession.all.map { |f| ["#{f.id}", f.id] }
     end
     f.actions
   end

  member_action :posts, method: :get do
    @post_creator = PostCreator.find(params[:id])
    @posts = Post.where(post_creator: @post_creator)
    render "admin/posts/_index_posts", context: self
  end

  show do
    attributes_table do
      row :account
      row :avatar do |ad|
        link_to ad.avatar, ad.avatar, target: "_blank"
      end
      row :url do |ad|
        link_to ad.url, ad.url, target: "_blank"
      end
    end
  end

  collection_action :posts, method: :get do
   @post_creator = PostCreator.find(params[:id])
   @posts = @post_creator.posts
   @page_title = "Publicaciones de (#{@posts.count})"
   @creators = []
   @columns = [["Fecha de publicación", "post_date"], ["Titulo", "title"]]
   @creators.push(["Todas las publicaciones", 0])
   PostCreator.all.map { |p| @creators.push([p.fan_page, p.id]) }
   @select = params[:post_creator_id] || 0
   @select_type_order = "DESC"

   render partial: "admin/posts/index_posts", context: self
 end


  collection_action :import_csv, method: :get do
    posts_creators = PostCreator.all
    csv = CSV.generate(encoding: "UTF-8") do |csv|
      csv << [ "Id", "fan_page", "url", "avatar", "created_at", "updated_at",
      "account", "cookie_info", "fb_session_id", "proxy_id", "get_likes", "fb_page_session"]
      posts_creators.each do |p|
        commentarry = [ p.id, p.fan_page, p.url, p.avatar, p.created_at, p.updated_at,
      p.account.try(:name), p.cookie_info, p.fb_session.try(:name), p.try(:proxy), p.get_likes, p.fb_page_session]
        csv << commentarry
      end
    end
    send_data csv.encode("UTF-8"), type: "text/csv; charset=windows-1251; header=present", disposition: "attachment; filename=post_creators.csv"
  end

  collection_action :search, method: :get do
    @post_creators = PostCreator.search(params[:channel], params[:column_order], params[:type_order])
    respond_to do |format|
      format.js
    end
  end

  controller do

    def index
      @post_creators = PostCreator.all.page(params[:page]).per(10)
      @page_title = "Publicadores (#{@post_creators.count})"
      @columns = [["Fan Page", "fan_page"], ["Cantidad de Publicaciones", 1]]
      respond_to do |format|
        format.html
        format.js { render "index", status: :ok }
      end
    end

    def destroy
      @post_creator = PostCreator.find(params[:id])

      PostCreator.transaction do
        begin
          @post_creator.destroy
          @post_creators = PostCreator.all.page(params[:page]).per(10)
          redirect_to admin_post_creators_path, notice: "Eliminado satisfactoriamente"
        rescue => e
          Rails.logger.info("destroy post creator failed")
          redirect_to admin_post_creators_path, alert: "No se pudo eliminar el publicador"
        end
      end
    end

    def posts
      @post_creator = PostCreator.find(params[:id])
      @posts = @post_creator.posts
      @page_title = "Publicaciones #{@post_creator.try(:fan_page)} (#{@posts.count})"
      @creators = []
      @columns = [["Fecha de publicación", "post_date"], ["Titulo", "title"]]
      @creators.push(["Todas las publicaciones", 0])
      PostCreator.all.map { |p| @creators.push([p.fan_page, p.id]) }
      @select = params[:id] || 0
      @select_type_order = "DESC"
    end
  end
end
