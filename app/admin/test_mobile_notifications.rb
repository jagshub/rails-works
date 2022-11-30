# frozen_string_literal: true

ActiveAdmin.register_page 'Test Mobile Notifications' do
  menu label: 'Test Mobile Notifications', parent: 'Others'

  page_action :create, method: :post do
    form = Admin::CreateTestMobileNotificationsForm.new(
      current_user: current_user,
    )

    if form.update(params)
      redirect_to admin_test_mobile_notifications_path, notice: 'Notification delivered. NOTE: clicking on notification will not lead to opening any particular post/comment in app.'
    else
      redirect_to admin_test_mobile_notifications_path, alert: form.errors
    end
  end

  content do
    div do
      label do
        link_to('How to use - Loom Video', 'https://www.loom.com/share/1ed0c65039ec40f8a00165915248092e')
      end
    end
    form(method: :post, action: admin_test_mobile_notifications_create_path) do |_f|
      input name: 'authenticity_token', type: :hidden, value: form_authenticity_token.to_s
      div do
        label do
          div 'Receiver'
          select name: 'receiver_id' do
            User.admin.each do |user|
              option value: user.id, selected: current_user.id == user.id do
                "#{ user.name } - ID: #{ user.id }"
              end
            end
          end
        end
      end

      div do
        label do
          div 'Notification type'
          select name: 'kind' do
            Admin::CreateTestMobileNotificationsForm::NOTIFICATIONS.keys.each do |type|
              option value: type do
                Admin::CreateTestMobileNotificationsForm::NOTIFICATIONS[type][:text]
              end
            end
          end
        end
      end

      div do
        label do
          div 'Comment Subject Type'
          div '(only required for mention push)'
          select name: 'subject_type' do
            Comment::SUBJECT_TYPES.each do |type|
              option value: type do
                type
              end
            end
          end
        end
      end

      div do
        label do
          div 'Subject id'
          input name: 'subject_id'
          div '(id for Subject Type if notification type is Mention)'
          div '(post_id if notification type is Friend Product Maker)'
          div '(user_id of the user who followed Receiver if type is New Follower)'
        end
      end

      input type: 'submit', value: 'Create'
    end
  end
end
