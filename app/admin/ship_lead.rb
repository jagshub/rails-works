# frozen_string_literal: true

ActiveAdmin.register ShipLead do
  config.batch_actions = false

  actions :index, :show

  config.per_page = 20
  config.paginate = true

  scope(:lead)
  scope(:customer)

  menu label: 'Leads', parent: 'Ship'

  filter :id
  filter :email
  filter :status
  filter :user_id
  filter :user_username, as: :string
  filter :user_name, as: :string

  filter :created_at

  index pagination_total: false do
    selectable_column

    column :id
    column :email
    column :status
    column :user
    column :ship_subscription

    column :created_at

    actions
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes([:user])
    end
  end
end
