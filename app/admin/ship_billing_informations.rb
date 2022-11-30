# frozen_string_literal: true

ActiveAdmin.register ShipBillingInformation do
  config.batch_actions = false

  actions :index, :show

  config.per_page = 20
  config.paginate = true

  permit_params(
    :user_id,
    :stripe_customer_id,
    :stripe_token_id,
    :billing_email,
    :ship_invite_code_id,
  )

  menu label: 'Billing Info', parent: 'Ship'

  filter :id
  filter :user_id
  filter :ship_invite_code
  filter :billing_email
  filter :stripe_customer_id
  filter :stripe_token_id
  filter :user_username, as: :string
  filter :user_name, as: :string

  index pagination_total: false do
    selectable_column

    column :id
    column :user
    column :billing_email
    column :ship_invite_code

    actions
  end

  form do |f|
    f.inputs 'Billing Information' do
      f.semantic_errors(*f.object.errors.attribute_names)
      f.input :user_id, as: :reference, label: 'User ID'
      f.input :stripe_customer_id
      f.input :stripe_token_id
      f.input :billing_email
      f.input :ship_invite_code
    end
    f.actions
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes([:user])
    end
  end
end
