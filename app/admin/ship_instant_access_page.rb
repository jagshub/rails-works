# frozen_string_literal: true

ActiveAdmin.register ShipInstantAccessPage do
  menu label: 'Promo Pages', parent: 'Ship'

  config.batch_actions = false

  actions :all

  config.per_page = 20
  config.paginate = true

  permit_params :name, :slug, :text, :ship_invite_code_id, :billing_periods

  filter :id
  filter :name
  filter :slug
  filter :ship_invite_code
  filter :created_at
  filter :trashed_at

  action_item :link, only: :show do
    link_to 'Link', ship_instant_access_page_path(ship_instant_access_page), target: '_blank', rel: 'noopener'
  end

  index pagination_total: false do
    selectable_column

    column :id
    column :slug

    column :name do |ship_instant_access_page|
      link_to ship_instant_access_page.name, Routes.ship_instant_access_page_path(ship_instant_access_page)
    end

    column :ship_invite_code
    column :created_at
    column :trashed_at

    column 'Link' do |page|
      link_to 'Link', ship_instant_access_page_path(page), target: '_blank', rel: 'noopener'
    end

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :name
      f.input :slug
      f.input :text
      f.input :billing_periods
      f.input :ship_invite_code
    end

    f.actions
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end

    def destroy
      if resource.trashed?
        redirect_to admin_ship_instant_access_pages_path, notice: 'ERROR: The instnat access page is already trashed, ask a developer if you need to restore it'
        return
      end

      resource.trash
      redirect_to admin_ship_instant_access_pages_path, notice: 'Instant Access Page trashed'
    end
  end
end
