# frozen_string_literal: true

ActiveAdmin.register ShipInviteCode do
  menu label: 'Promo Codes', parent: 'Ship'

  actions :all

  config.batch_actions = false

  config.per_page = 20
  config.paginate = true

  permit_params(
    :code,
    :discount_value,
    :description,
  )

  filter :id
  filter :code
  filter :discount_value

  index pagination_total: false do
    selectable_column

    column :id
    column :code
    column :description
    column :discount_value
    column :created_at

    actions
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      if f.object.new_record?
        f.input :code
        f.input :discount_value, hint: '20 means 20% etc.'
      end
      f.input :description, hint: "Hi there! Enjoy ...% off Ship's Pro plans 🙌"
    end

    f.actions
  end

  controller do
    def create
      @ship_invite_code = ShipInviteCode.new permitted_params[:ship_invite_code]

      ShipInviteCode.transaction do
        if @ship_invite_code.save && @ship_invite_code.discount?
          External::StripeApi.create_coupon(
            code: @ship_invite_code.code,
            percent_off: @ship_invite_code.discount_value,
          )
        end
      end

      respond_with @ship_invite_code, location: admin_ship_invite_codes_path
    end

    def destroy
      ShipInviteCode.transaction do
        resource.destroy!
        External::StripeApi.destroy_coupon(resource.code)
      end

      redirect_to admin_ship_invite_codes_path, notice: 'Invite Code deleted'
    end
  end

  show do
    default_main_content

    panel 'User who used the code' do
      table_for ship_invite_code.billing_informations do
        column :user do |billing_information|
          link_to billing_information.user.name, admin_user_path(billing_information.user)
        end
        column :subscription do |billing_information|
          subscription = billing_information.user.ship_subscription
          if subscription&.ended?
            'no active subscription'
          else
            "#{ subscription.billing_plan } ( #{ subscription.billing_period } ) - #{ subscription.status }"
          end
        end
        column :created_at
      end
    end
  end
end
