# frozen_string_literal: true

ActiveAdmin.register_page 'User Merge' do
  menu label: 'User Merge', parent: 'Users', priority: 1

  content do
    panel 'Merge User Accounts' do
      form action: admin_user_merge_create_path, method: :post, class: 'admin--user-merge--form' do |f|
        f.input name: 'authenticity_token', type: :hidden, value: form_authenticity_token.to_s
        f.label 'Result Username (the one that we want to keep)'
        f.input name: :result_username, placeholder: 'username', type: :text
        f.br
        f.div 'Note: If the user is a maker, we recommend that you use that one as the "Result Username"'
        f.br
        f.label 'Deleted Username(s) (the one that will be gone) - separate them with commas (user1,user2...)'
        f.input name: :trashed_username, placeholder: 'username(s)', type: :text
        f.br
        f.div 'This process will take a few minutes - you can confirm by going to the user profiles on the site.'
        f.br
        f.input type: :submit, value: 'Merge Accounts'
      end
    end
  end

  page_action :create, method: :post do
    result_user = User.find_by_username(params[:result_username])
    if result_user.blank?
      redirect_to admin_user_merge_path, notice: format('Error: Could not find %s, please retry.', params[:result_username])
      return
    end

    trashed_array = params[:trashed_username].split(',').map(&:strip)
    trashed_users = User.not_trashed.where(username: trashed_array)

    if trashed_array.size != trashed_users.size
      usernames = trashed_array - trashed_users.pluck(:username)

      redirect_to admin_user_merge_path, alert: format("Error: Could not find #{ usernames.size > 1 ? 'users with usernames:' : 'user with a username:' } #{ usernames.join(', ') }, please retry.")
      return
    end

    trashed_users.each { |user| Users.merge(result_user: result_user, trashed_user: user) }

    redirect_to admin_dashboard_path, notice: 'User merge started - this will take a few minutes'
  end
end
