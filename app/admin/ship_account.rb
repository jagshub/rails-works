# frozen_string_literal: true

ActiveAdmin.register ShipAccount do
  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  actions :index, :show, :edit

  menu label: 'Accounts', parent: 'Ship'

  scope(:accepted_dpa)
  scope(:declined_dpa)
  scope(:pending_dpa)

  filter :id
  filter :user_id
  filter :data_processor_agreement
  filter :user_username, as: :string
  filter :subscription_status, as: :check_boxes, collection: lambda {
    ShipSubscription.statuses.keys.map { |plan_name| [plan_name, ShipSubscription.statuses[plan_name]] }
  }
  filter :subscription_billing_plan, as: :check_boxes, collection: lambda {
    ShipSubscription.billing_plans.keys.map { |plan_name| [plan_name, ShipSubscription.billing_plans[plan_name]] }
  }
  filter :subscription_billing_period, as: :check_boxes, collection: lambda {
    ShipSubscription.billing_periods.keys.map { |plan_name| [plan_name, ShipSubscription.billing_periods[plan_name]] }
  }

  controller do
    def scoped_collection
      ShipAccount.includes(:user, :subscription)
    end
  end

  index do
    column :id
    column :username do |account|
      account.user.username
    end
    column :status do |account|
      account.subscription&.status
    end
    column :billing_plan do |account|
      account.subscription&.billing_plan
    end
    column :billing_period do |account|
      account.subscription&.billing_period
    end
    column :data_processor_agreement
    column :contacts_count
    column :created_at

    actions
  end

  show do
    default_main_content do
      row :data_processor_agreement
      row :contacts_count
      row :contacts_from_subscription_count
      row :contacts_from_reply_count
      row :contacts_from_import_count
    end

    panel 'Ship Subscription' do
      attributes_table_for ship_account.subscription do
        row :subscription_id do |subscription|
          link_to subscription.id, admin_ship_subscription_path(subscription)
        end
        row :status
        row :billing_plan
        row :billing_period
      end
    end

    panel 'Upcoming pages' do
      table_for ship_account.upcoming_pages do
        column :id
        column :name do |upcoming_page|
          link_to upcoming_page.name, upcoming_page_path(upcoming_page)
        end
        column :tagline
        column :status
        column :created_at
        column :featured_at
        column :trashed_at
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :name
      f.input :user_id, as: :reference, label: 'User ID'
    end

    f.actions
  end
end
