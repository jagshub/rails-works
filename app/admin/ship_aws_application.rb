# frozen_string_literal: true

ActiveAdmin.register ShipAwsApplication do
  config.batch_actions = false

  actions :index, :show

  config.per_page = 20
  config.paginate = true

  menu label: 'AWS Applications', parent: 'Ship'

  filter :id
  filter :startup_name
  filter :startup_email

  filter :created_at

  index pagination_total: false do
    selectable_column

    column :id
    column :startup_name
    column :startup_email

    column :credits do |resource|
      if resource.ship_account.subscription.blank?
        'Invalid Subscription'
      elsif resource.ship_account.subscription.pro?
        '$5,000'
      elsif resource.ship_account.subscription.super_pro?
        '$7,500'
      end
    end

    column :billing_plan do |resource|
      resource.ship_account&.subscription&.billing_plan
    end

    column :billing_period do |resource|
      resource.ship_account&.subscription&.billing_period
    end

    column :ship_account_owner_email do |resource|
      resource.ship_account&.user&.email
    end

    column :ship_account_owner_email do |resource|
      resource.ship_account&.user&.name
    end

    column :ship_account_billing_email do |resource|
      resource.ship_account&.subscription&.ship_billing_information&.billing_email
    end

    column :created_at

    actions
  end

  controller do
    def scoped_collection
      end_of_association_chain.reverse_chronological
    end
  end
end
