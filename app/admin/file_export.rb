# frozen_string_literal: true

ActiveAdmin.register FileExport do
  menu label: 'File exports', parent: 'Others'

  actions :index

  config.per_page = 20
  config.paginate = true

  filter :user_username, as: :string
  filter :user_id, as: :string

  controller do
    def scoped_collection
      FileExport.includes(:user)
    end
  end

  index do
    selectable_column

    column :id
    column 'user' do |file|
      link_to file.user.name, admin_user_path(file.user)
    end
    column :file_name
    column :note
    column 'Download File' do |export|
      if export.expires_at.future?
        link_to 'Download', Routes.download_export_url(export)
      else
        'Expired'
      end
    end

    actions
  end
end
