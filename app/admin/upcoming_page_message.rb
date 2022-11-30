# frozen_string_literal: true

ActiveAdmin.register UpcomingPageMessage do
  config.batch_actions = false

  actions :all, only: [:index]

  config.per_page = 20
  config.paginate = true

  menu label: 'Messages', parent: 'Ship'

  filter :id
  filter :state
  filter :upcoming_page_id
  filter :created_at

  index pagination_total: false do
    selectable_column

    column :id
    column :state

    column :subject do |message|
      link_to message.subject, upcoming_page_message_path(message)
    end

    column :user do |message|
      link_to message.author.username, admin_users_path(message.author)
    end

    column :upcoming_page do |message|
      link_to message.upcoming_page.name, upcoming_page_path(message.upcoming_page)
    end

    column :created_at
  end
end
