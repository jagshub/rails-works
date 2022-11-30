# frozen_string_literal: true

ActiveAdmin.register Products::ProductAssociation, as: 'ProductAssociation' do
  menu label: 'Product Associations', parent: 'Products'

  config.batch_actions = false
  config.per_page = 20
  config.paginate = true

  actions :all, except: %i(new create)

  filter :relationship, as: :select, collection: Products::ProductAssociation.relationships
  filter :product_name, as: :string
  filter :associated_product_name, as: :string

  permit_params(
    :post_id,
    :related_post_id,
    :relationship,
  )

  controller do
    def scoped_collection
      Products::ProductAssociation.includes(%i(product associated_product))
    end
  end

  index pagination_total: false do
    column :id
    column :product
    column :associated_product
    column :relationship
    column :source
    column :credible_votes_count
    column :created_at

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :product_id, as: :reference, label: 'Product ID'
      f.input :associated_product_id, as: :reference, label: 'Associated Product ID'
      f.input :relationship
    end

    f.actions
  end
end
