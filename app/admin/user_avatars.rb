# frozen_string_literal: true

ActiveAdmin.register_page 'User Avatars' do
  menu label: 'User Avatars', parent: 'Users'

  content do
    users = User.where.not(avatar_uploaded_at: nil).order(avatar_uploaded_at: :desc).includes(:subscriber).page(params[:page]).per(20)

    div do
      table_for(users) do
        column :id
        column :username
        column :email
        column :avatar do |user|
          user_image(user, size: 45)
        end
      end
    end

    div do
      paginate(
        users,
        theme: 'active_admin',
        params: params.permit!,
        param_name: :page,
        total_pages: users.current_page + 1,
        right: 0,
      )
    end
  end
end
