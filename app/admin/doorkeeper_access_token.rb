# frozen_string_literal: true

ActiveAdmin.register Doorkeeper::AccessToken do
  menu label: 'OAuth Access Tokens', parent: 'Others'

  actions :index, :destroy

  includes :application

  config.sort_order = 'created_at_desc'
  config.batch_actions = true
  config.per_page = 20
  config.paginate = true

  filter :resource_owner_id, label: 'User ID'
  filter :application_id, label: 'Application ID'

  scope(:all, default: true)
  scope('Public') { |scope| scope.where("scopes LIKE '%public%'") }
  scope('Private') { |scope| scope.where("scopes LIKE '%private%'") }
  scope('Write') { |scope| scope.where("scopes LIKE '%write%'") }

  index do
    selectable_column

    column :application
    column :resource_owner_id
    column :created_at
    column :scopes

    actions
  end
end
