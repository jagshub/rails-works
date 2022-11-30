# frozen_string_literal: true

ActiveAdmin.register Team::Member do
  menu label: 'Team members', parent: 'Products'

  actions :all

  config.batch_actions = false
  config.per_page = 20

  filter :user_id, label: 'User ID'
  filter :product_name, as: :string
  filter :role, as: :select, collection: Team::Member.roles
  filter :status, as: :select, collection: Team::Member.statuses

  index pagination_total: true do
    column :id
    column :user
    column :product
    column :role
    column :status
    column :status_changed_at
    column :position
    column :team_email
    column :created_at

    actions
  end

  permit_params %i(
    user_id
    product_id
    referrer_id
    referrer_type
    role
    status
    position
    team_email
  )

  show do
    default_main_content

    render 'admin/shared/audits'
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs 'Team member details' do
      f.input :user_id, as: :reference, label: 'User ID'
      f.input :product_id, as: :reference, label: 'Product ID'
      f.input :referrer_id, as: :reference, label: 'Referrer ID'
      f.input :referrer_type, as: :select, collection: Team::Member::REFERRER_TYPES
      f.input :role, as: :select, collection: Team::Member.roles
      f.input :status, as: :select, collection: Team::Member.statuses
      f.input :position
      f.input :team_email, required: false
    end

    f.actions
  end
end
