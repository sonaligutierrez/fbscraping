ActiveAdmin.register FbSession do
  permit_params :name, :disabled
  menu label: proc { I18n.t("active_admin.fb_sessions") }, priority: 9
  index do
    selectable_column
    id_column
    column :disabled
    column :created_at
    column :updated_at
    actions
  end


  form do |f|
    f.inputs do
      f.input :name, as: :text, label: "Datos JSON de la sesión"
      f.input :disabled
    end
    f.actions
  end

end
