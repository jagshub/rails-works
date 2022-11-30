# frozen_string_literal: true

ActiveAdmin.register ShipCancellationReason do
  config.batch_actions = false

  actions :index, :show

  config.per_page = 20
  config.paginate = true

  menu label: 'Cancellations', parent: 'Ship'

  filter :id
  filter :user_id

  filter :created_at

  index pagination_total: false do
    selectable_column

    column :id
    column :user
    column :billing_plan
    column :reason
    column :created_at

    actions
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes([:user])
    end
  end
end
