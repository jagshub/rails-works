# frozen_string_literal: true

ActiveAdmin.register Jobs::DiscountPage do
  menu parent: 'Jobs', label: 'Discount Pages'

  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  scope(:active, default: true, &:not_trashed)
  scope(:trashed, &:trashed)

  filter :id
  filter :name

  permit_params(
    :name,
    :text,
    :slug,
    :discount_value,
    discount_plan_ids: [],
  )

  index pagination_total: false do
    selectable_column

    column :id
    column :name
    column :discount_value do |page|
      "#{ page.discount_value }%"
    end
    column :plans do |page|
      page.discount_plan_ids.map do |id|
        Jobs::Plans.find_by_id(id).description
      end.join(', ')
    end
    column :jobs_count
    column :created_at
    column 'Link' do |page|
      link_to 'Link', jobs_discount_page_path(page.slug), target: '_blank', rel: 'noopener'
    end

    actions
  end

  action_item :link, only: :show do
    link_to 'Link', jobs_discount_page_path(jobs_discount_page.slug), target: '_blank', rel: 'noopener'
  end

  controller do
    def create
      @jobs_discount_page = Jobs::DiscountPage.new permitted_params[:jobs_discount_page]

      ShipInviteCode.transaction do
        if @jobs_discount_page.save
          External::StripeApi.create_coupon(
            code: @jobs_discount_page.stripe_coupon_code,
            name: @jobs_discount_page.name,
            percent_off: @jobs_discount_page.discount_value,
          )
        end
      end

      respond_with @jobs_discount_page, location: admin_jobs_discount_pages_path
    end

    def destroy
      ShipInviteCode.transaction do
        resource.destroy!
        External::StripeApi.destroy_coupon(resource.stripe_coupon_code)
      end

      redirect_to admin_ship_invite_codes_path, notice: 'Discount was deleted'
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.semantic_errors(*f.object.errors.attribute_names)

      f.input :name
      f.input :slug, hint: %(Used for the url of the page "#{ Routes.jobs_discount_page_url('[SLUG]') }")
      f.input :text, hint: %(You can use HTML tags like <strong>bold text</strong> and <mark>orange text</mark>)
    end

    f.inputs 'Discount' do
      f.input :discount_value, hint: '20 means 20% etc.' if f.object.new_record?
      f.input :discount_plan_ids, as: :select, collection: Jobs::Plans.plans.map { |plan| [plan.description, plan.id] }, multiple: true, input_html: { style: 'display: block' }, hint: 'You can pick multiple plans. (Shift + Click)'
    end

    f.actions
  end

  show do
    default_main_content

    panel 'Jobs who used the page' do
      table_for jobs_discount_page.jobs do
        column :id do |job|
          link_to job.id, admin_job_path(job)
        end
        column :email
        column :billing_email
        column :company_name
        column :job_title
        column :slug
        column :published
        column :stripe_subscription_id
        column :created_at
      end
    end
  end
end
