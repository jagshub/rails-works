# frozen_string_literal: true

ActiveAdmin.register_page 'Marketing Notifications' do
  menu label: 'Marketing Notifications', parent: 'Others'

  page_action :create, method: :post do
    form = Admin::CreateMarketingNotificationsForm.new(
      current_user: current_user,
    )

    if form.update(params)
      redirect_to admin_marketing_notifications_path, notice: 'Notification delivered.'
    else
      redirect_to admin_marketing_notifications_path, alert: form.errors
    end
  end

  content do
    form(method: :post, action: admin_marketing_notifications_create_path) do |_f|
      input name: 'authenticity_token', type: :hidden, value: form_authenticity_token.to_s
      div do
        label do
          div 'User IDs'
          div 'comma (,) separated user IDs'
          input name: 'user_ids', type: :text
        end
      end

      div do
        label do
          div 'PN Heading'
          input name: 'heading', type: :text
        end
      end

      div do
        label do
          div 'PN Body'
          input name: 'body', type: :text
        end
      end

      div do
        label do
          div 'PN Text One Liner'
          input name: 'one_liner', type: :text
        end
      end

      div do
        label do
          div 'PN Deeplink'
          div 'if want to open specific screen in app (example: producthunt://home)'
          input name: 'deeplink', type: :text
        end
      end

      input type: 'submit', value: 'Send'
    end
  end
end
