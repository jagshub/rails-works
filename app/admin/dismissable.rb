# frozen_string_literal: true

ActiveAdmin.register ::Dismissable do
  menu label: 'Dismissed', parent: 'Others'

  actions :index, :destroy

  config.per_page = 20
  config.paginate = true

  filter :user_username, as: :string
  filter :user_id, as: :string

  controller do
    def scoped_collection
      Dismissable.includes(:user)
    end
  end

  index do
    selectable_column

    column :id
    column 'user' do |dismissable|
      link_to dismissable.user.name, admin_user_path(dismissable.user)
    end
    column :dismissable_key

    actions
  end
end
