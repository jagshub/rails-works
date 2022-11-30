# frozen_string_literal: true

ActiveAdmin.register Payment::Subscription, as: 'PaymentSubscription' do
  menu label: 'Payments -> Susbcriptions', parent: 'Revenue'

  actions :index, :show

  includes :user, :plan, :discount

  config.sort_order = 'created_at_desc'
  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  scope :reverse_chronological, show_count: false, default: true
  scope :active
  scope :expired
  scope :canceled
  scope :not_canceled
  scope :refunded

  permit_params(
    :stripe_subscription_id,
    :refund_reason,
  )

  filter :project, as: :select, collection: ::Payment::Subscription.projects.keys.to_a
  filter :user_id, label: 'User ID'
  filter :plan
  filter :discount
  filter :marketing_campaign_name

  index pagination_total: false do
    column :id
    column :created_at
    column :project
    column :plan
    column :discount
    column :user
    column :charged_amount_in_cents, sortable: true do |resource|
      "$#{ resource.charged_amount_in_cents / 100 }"
    end
    column :status do |resource|
      payment_subscription_status(resource)
    end

    column :stripe_link do |resource|
      link_to 'Link', External::StripeApi.subscription_url(resource.stripe_subscription_id), target: '_blank', rel: 'noopener'
    end

    column :campaign, sortable: :marketing_campaign_name, &:marketing_campaign_name

    actions
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :amount do |resource|
        "$#{ resource.plan_amount_in_cents / 100 }"
      end
      row :project
      row :plan
      row :discount
      row :user

      row :stripe_subscription do |resource|
        link_to resource.stripe_subscription_id, External::StripeApi.subscription_url(resource.stripe_subscription_id), target: '_blank', rel: 'noopener'
      end
      row :stripe_customer do |resource|
        link_to resource.stripe_customer_id, External::StripeApi.customer_url(resource.stripe_customer_id), target: '_blank', rel: 'noopener'
      end
      row :stripe_coupon_code do |resource|
        link_to resource.stripe_coupon_code, External::StripeApi.coupon_url(resource.stripe_coupon_code), target: '_blank', rel: 'noopener' if resource.stripe_coupon_code.present?
      end
      row :stripe_refund_id

      row :expired_at
      row :user_canceled_at
      row :stripe_canceled_at
      row :refunded_at
      row :renew_notice_sent_at
      row :cancellation_reason
      row :marketing_campaign_name
    end
  end

  action_item :refund, only: :show, if: proc { resource.refund? } do
    link_to 'Refund Subscription', action: :refund
  end

  member_action :refund do
    @refund_form = Admin::Payment::RefundSubscriptionForm.new resource
  end

  member_action :refund_subscription, method: :post do
    till_the_end_of_the_billing_period = permitted_params[:payment_subscription].delete(:till_the_end_of_the_billing_period)

    @refund_form = Admin::Payment::RefundSubscriptionForm.new resource, till_the_end_of_the_billing_period
    @refund_form.update permitted_params[:payment_subscription]

    if @refund_form.errors.present?
      redirect_to refund_admin_payment_subscription_path(resource), alert: @refund_form.errors.full_messages.to_sentence
    else
      redirect_to admin_payment_subscription_path(resource), notice: 'Subscription refund initiated!'
    end
  end
end
