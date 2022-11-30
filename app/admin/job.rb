# frozen_string_literal: true

ActiveAdmin.register Job do
  menu label: 'Jobs'

  Admin::AddTrashing.call(self)

  scope :with_active_subscription, &:with_active_subscription
  scope(:with_canceled_subscription) { |scope| scope.where.not(stripe_subscription_id: nil).where.not(cancelled_at: nil) }
  scope :featured_in_homepage, &:featured_in_homepage

  permit_params :published, :image, :company_name, :company_tagline, :job_title, :url, :locations, :locations_csv, :categories, :categories_csv, :remote_ok, :feature_homepage, :feature_job_digest, :feature_newsletter, :product_id

  filter :id
  filter :company_name, as: :string
  filter :job_title, as: :string
  filter :stripe_billing_email
  filter :kind, as: :select, collection: Job.kinds
  filter :feature_homepage, as: :boolean
  filter :feature_job_digest, as: :boolean
  filter :feature_newsletter, as: :boolean

  index pagination_total: false do
    selectable_column

    column :id
    column :billing_email
    column :company_name
    column :product
    column :job_title
    column :published
    column :feature_homepage
    column :feature_job_digest
    column :feature_newsletter
    column :stripe_subscription_id do |resource|
      link_to 'Subscription in stripe', External::StripeApi.subscription_url(resource.stripe_subscription_id), target: :blank
    end
    column :created_at
    column :cancelled_at
    column :renew_notice_sent_at
    column 'extras', :extra_packages

    column 'Links' do |link|
      link_to 'Public Edit Link', Routes.edit_job_path(link), target: :blank
    end

    actions
  end

  action_item :edit_link, only: %i(edit show), if: proc { resource.token? } do
    link_to 'Public Edit Link', Routes.edit_job_path(resource), target: :blank
  end

  action_item :bump, only: %i(show) do
    link_to 'Bump To Top', bump_admin_job_path(resource)
  end

  member_action :bump do
    resource.update!(last_payment_at: Time.current)

    redirect_to resource_path, notice: 'Job Post Bumped'
  end

  form do |f|
    if f.object.errors.any?
      f.inputs 'Errors' do
        f.object.errors.full_messages.join('|')
      end
    end
    f.inputs 'Details' do
      f.input :company_name, as: :string, placeholder: 'Facebook'
      f.input :company_tagline, as: :string, placeholder: 'Awesome social network'
      f.input :job_title, as: :string, placeholder: 'Senior UX Designer'
      f.input :url, as: :string, placeholder: 'http://facebook.com/about/jobs'
      f.input :image, as: :file, hint: image_preview_hint(f.object.image_url, 'Company Logo')
      f.input :remote_ok
      f.input :published
      f.input :feature_homepage, as: :boolean
      f.input :feature_job_digest, as: :boolean
      f.input :feature_newsletter, as: :boolean
      f.input :locations_csv
      f.input :categories_csv
      f.input :product_id,
              as: :number,
              label: 'Product ID',
              hint: (link_to(f.object.product.name, admin_product_path(f.object.product)) if f.object.product.present?)
    end
    f.actions
  end

  controller do
    before_action only: :index do
      params.merge!('q' => { kind_eq: 0 }) if params[:commit].blank? && params[:q].blank?
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end
end
