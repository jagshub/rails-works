# frozen_string_literal: true

ActiveAdmin.register Collection do
  menu label: 'Collections', parent: 'Products'

  config.sort_order = 'created_at_desc'

  filter :name
  filter :title
  filter :subscriber_count
  filter :user_username, as: :string
  filter :featured_at

  scope(:all, default: true)
  scope(:featured) { |scope| scope.where.not(featured_at: nil) }

  show do
    default_main_content
    panel 'Products' do
      table_for collection.products do
        column :name
        column :created_at
        column 'Edit' do |product|
          link_to 'Edit', edit_admin_product_url(product.slug)
        end
        column 'Delete' do |product|
          link_to 'Delete', admin_product_url(product.slug), method: :delete
        end
      end
    end

    active_admin_comments
  end

  index do
    selectable_column
    column :user
    column :name
    column :title
    column :slug
    column :subscriber_count
    column :created_at
    column :featured_at

    column 'Products' do |collection|
      collection.products.pluck(:name).join(', ')
    end
    column 'Edit' do |collection|
      link_to 'Edit', edit_admin_collection_url(collection.id)
    end
    column 'Show' do |collection|
      link_to 'Show', admin_collection_url(collection.id)
    end
    column 'View on Site' do |collection|
      link_to 'View on Site', Routes.collection_path(collection), target: '_blank', rel: 'noopener'
    end
  end

  permit_params Admin::CollectionForm.attributes,
                collection_product_associations_attributes: %i(id product_id _destroy)

  controller do
    def new
      @collection = Admin::CollectionForm.new current_user
    end

    def create
      @collection = Admin::CollectionForm.new current_user
      @collection.update permitted_params[:collection]

      respond_with @collection, location: admin_collections_path
    end

    def edit
      @collection = Admin::CollectionForm.new current_user, Collection.find(params[:id])
    end

    def update
      @collection = Admin::CollectionForm.new current_user, Collection.find(params[:id])

      @collection.update permitted_params[:collection]
      respond_with @collection, location: admin_collections_path
    end
  end

  form do |f|
    f.inputs 'Collection', html: { enctype: 'multipart/form-data' } do
      f.semantic_errors(*f.object.errors.attribute_names)
      f.input :name, as: :string
      f.input :description, as: :text
      f.input :title, as: :string
      f.input :slug, as: :string
      f.input :user_id, as: :reference, label: 'Created by - User ID'
      f.input :featured_at, as: :datetime_picker, hint: 'If you provide a date in future it won\'t appear before that'
      f.has_many :collection_product_associations, allow_destroy: true, heading: 'Existing products' do |form|
        form.input :product_id, as: :reference, label: 'Product ID'
      end
    end
    f.actions
  end

  controller do
    def scoped_collection
      Collection.includes(:user, :products)
    end
  end
end
