# frozen_string_literal: true

ActiveAdmin.register ShipSubscription do
  config.batch_actions = false

  actions :index, :show, :edit, :update

  permit_params :user_id, :billing_plan, :billing_period, :status, :ends_at, :cancelled_at, :trial_ends_at

  config.per_page = 20
  config.paginate = true

  scope(:premium)
  scope(:free)
  scope(:cancelled)

  menu label: 'Customers', parent: 'Ship'

  filter :id
  filter :user_id
  filter :user_username, as: :string
  filter :user_name, as: :string
  filter :created_at
  filter :cancelled_at
  filter :ends_at

  index pagination_total: false do
    selectable_column

    column :id
    column :user

    column :email do |resource|
      resource.user.email
    end

    column :billing_email do |resource|
      resource.user.ship_billing_information&.billing_email
    end

    column :source do |resource|
      resource.user.ship_instant_access_page&.slug
    end

    column :status
    column :billing_plan
    column :billing_period

    column :cancelled_at
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :user

      row :headline do
        resource.user.headline
      end

      row :email do |resource|
        resource.user.email
      end

      row :billing_email do |resource|
        resource.user.ship_billing_information&.billing_email
      end

      row :source do |resource|
        resource.user.ship_instant_access_page&.slug
      end

      row :billing_plan
      row :billing_period

      row :created_at
      row :cancelled_at
      row :ends_at
    end

    resource.user.upcoming_pages.map do |upcoming_page|
      panel upcoming_page.name do
        attributes_table_for upcoming_page do
          row :id
          row :name do
            link_to upcoming_page.name, upcoming_page_path(upcoming_page), target: '_blank', rel: 'noopener'
          end
          row :tagline
          row :status
          row :subscriber_count
          row :imported_subscriber_count do
            upcoming_page.subscribers.imported.count
          end
          row :created_at
          row :featured_at
        end

        table_for upcoming_page.maker_tasks do
          column :id
          column :title
          column :completed_at
        end
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :user_id, as: :reference, label: 'User ID'
      f.input :billing_plan
      f.input :billing_period
      f.input :status
      f.input :ends_at
      f.input :cancelled_at
      f.input :trial_ends_at
    end

    f.actions
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes([:user])
    end
  end
end
