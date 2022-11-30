# frozen_string_literal: true

ActiveAdmin.register UpcomingPageEmailReply do
  actions :index, :show

  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  menu label: 'Message Email Replies', parent: 'Ship'

  filter :from_eq, label: 'From'
  filter :to_eq, label: 'To'
  filter :custom_id_eq, label: 'Custom Id'

  scope(:all, default: true)
  scope(:handled, &:handled)
  scope(:not_handled, &:not_handled)

  index do
    column :id
    column :created_at
    column :to do |reply|
      reply.payload['Recipient']
    end
    column :from do |reply|
      reply.payload['From']
    end
    column :subject do |reply|
      reply.payload['Subject']
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :updated_at

      row 'Upcoming page' do |reply|
        link_to reply.conversation_message.upcoming_page.name, upcoming_page_path(reply.conversation_message.upcoming_page) if reply.conversation_message
      end

      row 'Message' do |reply|
        link_to reply.conversation_message.upcoming_page_message.subject, my_upcoming_page_message_path(reply.conversation_message.upcoming_page, reply.conversation_message.upcoming_page_message) if reply.conversation_message
      end

      row :custom_id do |reply|
        reply.payload['CustomID']
      end

      row :from do |reply|
        reply.payload['From']
      end

      row :to do |reply|
        reply.payload['Recipient']
      end

      row :subject do |reply|
        reply.payload['Subject']
      end

      row :text do |reply|
        content_tag :pre, reply.payload['Text-part']
      end

      row :payload do |reply|
        content_tag :pre, JSON.pretty_generate(reply.payload)
      end
    end
  end
end
