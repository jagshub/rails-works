# frozen_string_literal: true

ActiveAdmin.register Products::Category, as: 'Product Category' do
  Admin::UseForm.call self, Products::Admin::CategoryForm

  menu label: 'Categories', parent: 'Products'

  filter :id
  filter :slug
  filter :name

  index do
    column :id
    column :slug
    column :name
    column :reviewed
    column :products_count
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs 'Category Configuration' do
      f.input :name, required: true
      f.input :slug, hint: 'Leave blank to auto-generate'
      f.input :description
      f.input :reviewed, as: :boolean

      f.input :parent_id,
              as: :select,
              collection: Products::Category.order(:name).map { |pc| [pc.name, pc.id] }
    end

    f.actions
  end
end
