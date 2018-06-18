class Post < ApplicationRecord
  belongs_to :post_creator
  has_many :post_comments
  has_many :scraping_logs

  validates :post_creator, :url, presence: true

  def scraping
    fb_scraping = FacebookPostScraping.new(url, post_creator.fb_user, post_creator.fb_pass, post_creator.fb_session)

    count = 0
    # Login
    if fb_scraping.login
      post_creator.fb_session = fb_scraping.get_cookie_yml
      post_creator.save
      fb_scraping.process
      fb_scraping.comments.each do |comment|
        puts "Ingresando: " + comment[1][:user]
        fb_user = FacebookUser.where(fb_username: comment[1][:url_profile]).first_or_create(fb_name: comment[1][:user])
        if fb_user
          the_comment = PostComment.find_by_id_comment(comment[0])
          if the_comment
            the_comment.update(date_comment: comment[1][:date_comment], reactions: comment[1][:reactions], reactions_description: comment[1][:reactions_description], responses: comment[1][:responses])
          else
            the_comment = PostComment.create(post_id: id, facebook_user_id: fb_user.id, id_comment: comment[0], date_comment: comment[1][:date_comment], reactions: comment[1][:reactions], reactions_description: comment[1][:reactions_description], responses: comment[1][:responses], category_id: Category.find_by_name("Uncategorized").id, comment: comment[1][:comment])
          end
          count += 1 if the_comment
        end
      end
    end
    count
  end

  def count_comments_uncategorized
    post_comments.joins(:category).where("categories.name LIKE ?",'Uncategorized').count
  end

  def count_comments_categorized
    post_comments.joins(:category).where("categories.name NOT LIKE ?",'Uncategorized').count
  end

  def uncategorized_porcent
    if post_comments.count > 0
      (count_comments_uncategorized * 100) / post_comments.count
    else
      0
    end
  end
end
