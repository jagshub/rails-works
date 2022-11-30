# frozen_string_literal: true

ActiveAdmin.register_page 'Test Activity Feed' do
  menu label: 'Test Activity Feed', parent: 'Others'

  page_action :create, method: :post do
    result, message = Admin::CreateTestActivityFeedItemForm.create(
      user_id: params[:user_id],
      feed_item_type: params[:feed_item_type],
      subject_id: params[:subject_id],
      actor_id: params[:actor_id],
    )

    if result
      redirect_to admin_test_activity_feed_path, notice: message
    else
      redirect_to admin_test_activity_feed_path, alert: message
    end
  end

  content do
    form(method: :post, action: admin_test_activity_feed_create_path) do
      input name: 'authenticity_token', type: :hidden, value: form_authenticity_token.to_s
      div do
        label do
          div 'Receiver'
          select name: 'user_id' do
            User.admin.each do |user|
              option value: user.id, selected: current_user.id == user.id do
                user.name
              end
            end
          end
        end
      end

      div do
        label do
          div 'Feed item'
          select name: 'feed_item_type' do
            Admin::CreateTestActivityFeedItemForm::FEED_ITEMS.keys.each do |type|
              option value: type do
                "#{ type }. Expect subject type #{ Admin::CreateTestActivityFeedItemForm::SUBJECTS[type] }"
              end
            end
          end
        end
      end

      div do
        label do
          div 'Subject id'
          input name: 'subject_id'
        end
      end

      div do
        label do
          div 'Actor id'
          input name: 'actor_id'
          div '(can be blank then Receiver is also the Actor)'
        end
      end

      input type: 'submit', value: 'Create'
    end
  end
end
