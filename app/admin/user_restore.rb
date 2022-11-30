# frozen_string_literal: true

ActiveAdmin.register User, as: 'UserRestore' do
  menu label: 'Restore User', parent: 'Users'

  actions :index, :edit, :update

  permit_params(*Admin::UserRestoreForm.attribute_names)

  controller do
    def edit
      @user = Admin::UserRestoreForm.new User.find(params[:id])
    end

    def update
      @user = Admin::UserRestoreForm.new User.find(params[:id])

      @user.update permitted_params[:user]

      if @user.errors.empty?
        redirect_to admin_user_restores_path
      else
        # Note(rahul): Flash is used because `form` gets `User` instead of `UserRestoreForm` object
        flash.now[:error] = @user.errors.full_messages.to_sentence
        respond_with @user, location: admin_user_restores_path
      end
    end
  end

  config.per_page = 20
  config.paginate = true

  filter :username

  index pagination_total: false do
    selectable_column
    column :id
    column :name do |user|
      formatted_user_name(user)
    end
    column :username
    column :headline
    column :email
    column :beta_tester
    column 'Total Votes' do |user|
      user.post_votes.count
    end

    column :role do |user|
      formatted_user_role(user)
    end

    column 'Restore' do |user|
      link_to 'Restore', edit_admin_user_restore_url(user.id)
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :username
      f.input :twitter_username
      SignIn::SOCIAL_ATTRIBUTES.each do |attribute_name|
        f.input attribute_name
      end
    end
    f.actions
  end
end
