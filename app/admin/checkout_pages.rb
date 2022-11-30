# frozen_string_literal: true

ActiveAdmin.register CheckoutPage do
  menu parent: 'Revenue', label: 'Promoted -> Checkout Pages'

  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  scope(:active, default: true, &:not_trashed)
  scope(:trashed, &:trashed)

  permit_params(
    :name,
    :sku,
    :kind,
    :body,
  )

  filter :id
  filter :name
  filter :slug
  filter :created_at

  index pagination_total: false do
    selectable_column

    column :id
    column :name do |resource|
      link_to resource.name, checkout_page_path(resource)
    end
    column :slug
    column :sku
    column :kind
    column :body

    column :created_at
    column :trashed_at

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.semantic_errors(*f.object.errors.attribute_names)

      f.input :sku unless resource.persisted?
      f.input :kind unless resource.persisted?

      f.input :name
      f.input :body, hint: 'Supports HTML'
    end

    f.actions
  end

  show do
    default_main_content
  end

  controller do
    def find_resource
      CheckoutPage.friendly.find(params[:id])
    end

    def create
      @checkout_page = CheckoutPage.new(permitted_params[:checkout_page])

      if CheckoutPages::PaymentType.new(@checkout_page).exists?
        super
      else
        @checkout_page.valid?
        @checkout_page.errors.add(:sku, 'does not exist in Stripe')

        respond_with @checkout_page, location: admin_checkout_pages_path
      end
    end

    def destroy
      if resource.trashed?
        redirect_to admin_checkout_pages_path, notice: 'ERROR: Already trashed, ask a developer if you need to restore them'
        return
      end

      resource.trash
      redirect_to admin_checkout_pages_path, notice: 'Checkout Page trashed'
    end
  end
end
