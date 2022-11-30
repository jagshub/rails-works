# frozen_string_literal: true

ActiveAdmin.register ReviewTag do
  config.batch_actions = false

  menu label: 'Review Tags', parent: 'Products'

  filter :id
  filter :property
  filter :positive_label
  filter :negative_label

  permit_params :property, :positive_label, :negative_label

  form do |f|
    f.inputs 'Details' do
      f.input :property, required: true
      f.input :positive_label
      f.input :negative_label
    end

    f.actions
  end

  index do
    column :id
    column :property

    column :positive_label
    column 'Positive Associations' do |review|
      review.review_associations.positive.count
    end

    column :negative_label
    column 'Negative Associations' do |review|
      review.review_associations.negative.count
    end

    column :created_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :property

      row :positive_label
      row 'Positive Associations' do |review|
        review.review_associations.positive.count
      end

      row :negative_label
      row 'Negative Associations' do |review|
        review.review_associations.negative.count
      end

      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
