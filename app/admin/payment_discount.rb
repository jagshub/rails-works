# frozen_string_literal: true

ActiveAdmin.register Payment::Discount, as: 'PaymentDiscount' do
  menu label: 'Payments -> Discounts', parent: 'Revenue'

  actions :all, except: %i(destroy)

  includes :plans

  config.sort_order = 'created_at_desc'
  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  filter :active

  scope :reverse_chronological, show_count: false

  permit_params(
    :percentage_off,
    :name,
    :description,
    :active,
    :code,
    plan_ids: [],
  )

  index pagination_total: false do
    selectable_column

    column :id
    column :created_at
    column :active
    column :stripe_coupon_code
    column :name
    column :code
    column :percentage_off do |page|
      "#{ page.percentage_off }%"
    end
    column :plans do |page|
      page.plans.map(&:name).join(', ')
    end
    column :stripe_coupon do |page|
      link_to 'Link', External::StripeApi.coupon_url(page.stripe_coupon_code), target: '_blank', rel: 'noopener'
    end

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :active, as: :boolean
      if f.object.new_record?
        f.input :name, hint: 'e.g "Deals Early Bird"'
        f.input :percentage_off, hint: '20 means 20% etc.'
      end
      f.input :code, hint: 'Discount code'
      f.input :description, hint: 'Hi there! Enjoy ...% off Deals plans 🙌'
      f.input :plan_ids, label: 'Plans', as: :select, collection: Payment::Plan.active.map { |plan| [plan.name, plan.id] }, multiple: true, input_html: { style: 'display: block' }, hint: 'Choose atleast one plan. You can pick multiple plans. (Shift + Click)'
    end

    f.actions
  end

  controller do
    def new
      @payment_discount = Admin::Payment::DiscountForm.new
    end

    def create
      @payment_discount = Admin::Payment::DiscountForm.new
      @payment_discount.update permitted_params[:payment_discount]

      respond_with @payment_discount, location: admin_payment_discounts_path
    end

    def edit
      @payment_discount = Admin::Payment::DiscountForm.new ::Payment::Discount.find(params[:id])
    end

    def update
      @payment_discount = Admin::Payment::DiscountForm.new ::Payment::Discount.find(params[:id])
      @payment_discount.update permitted_params[:payment_discount]

      respond_with @payment_discount, location: admin_payment_discounts_path
    end
  end
end
