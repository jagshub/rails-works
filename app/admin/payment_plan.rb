# frozen_string_literal: true

ActiveAdmin.register Payment::Plan, as: 'PaymentPlan' do
  menu label: 'Payments -> Plans', parent: 'Revenue'

  actions :all, except: %i(destroy)

  includes :discounts

  config.sort_order = 'created_at_desc'
  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  filter :project
  filter :period_in_months

  scope :reverse_chronological, show_count: false

  permit_params(
    :active,
    :amount_in_cents,
    :period_in_months,
    :project,
    :stripe_plan_id,
    :name,
    :description,
    discount_ids: [],
  )

  index pagination_total: false do
    selectable_column
    column :id
    column :project
    column :active
    column :name
    column :amount do |page|
      "$#{ page.amount_in_cents / 100 }"
    end
    column :active_discounts do |page|
      page.discounts.active.map(&:name).join(', ')
    end
    column :period_in_months
    column :stripe_plan_id
    column :created_at
    column :stripe_link do |page|
      link_to 'Link', External::StripeApi.plan_url(page.stripe_plan_id), target: '_blank', rel: 'noopener'
    end

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :active, as: :boolean, input_html: f.object.new_record? ? { checked: 'checked' } : nil

      if f.object.new_record?
        f.input :stripe_plan_id, label: 'Stripe Plan ID', hint: 'Create plan on stripe and add its ID here'
        f.input :project, as: :select, collection: Payment::Plan.projects.keys, input_html: { style: 'display: block' }
        f.input :name
      end

      f.input :discount_ids, label: 'Discounts', as: :select, collection: Payment::Discount.active.map { |discount| [discount.name, discount.id] }, multiple: true, input_html: { style: 'display: block' }, hint: 'Choose applicable discounts, You can pick multiple discounts. (Shift + Click)'
      f.input :description
    end

    f.actions
  end

  controller do
    def new
      @payment_plan = Admin::Payment::PlanForm.new
    end

    def create
      @payment_plan = Admin::Payment::PlanForm.new
      @payment_plan.update permitted_params[:payment_plan]

      respond_with @payment_plan, location: admin_payment_plans_path
    end

    def edit
      @payment_plan = Admin::Payment::PlanForm.new ::Payment::Plan.find(params[:id])
    end

    def update
      @payment_plan = Admin::Payment::PlanForm.new ::Payment::Plan.find(params[:id])
      @payment_plan.update permitted_params[:payment_plan]

      respond_with @payment_plan, location: admin_payment_plans_path
    end
  end
end
