# frozen_string_literal: true

ActiveAdmin.register OAuth::Request do
  menu label: 'OAuth App Requests', parent: 'Others'

  actions :index

  includes :user, :application

  config.sort_order = 'last_request_at_desc'
  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  filter :user_id, label: 'User ID'
  filter :application_id, label: 'Application ID'

  index do
    column :id
    column :application
    column :user
    column :last_request_at

    actions
  end
end
