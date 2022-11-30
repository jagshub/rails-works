# frozen_string_literal: true

ActiveAdmin.register CheckoutPageLog do
  menu parent: 'Revenue', label: 'Promoted -> Checkout Page Logs'

  actions :index, :show

  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  filter :id
  filter :name
  filter :slug
  filter :created_at

  index pagination_total: false do
    selectable_column

    column :id
    column :checkout_page
    column :user
    column :billing_email
    column :created_at

    actions
  end
end
