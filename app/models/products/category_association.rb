# frozen_string_literal: true

# == Schema Information
#
# Table name: product_category_associations
#
#  id          :bigint(8)        not null, primary key
#  product_id  :bigint(8)        not null
#  category_id :bigint(8)        not null
#  source      :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_product_category_associations_on_category_id           (category_id)
#  index_product_category_associations_on_product_and_category  (product_id,category_id) UNIQUE
#
class Products::CategoryAssociation < ApplicationRecord
  self.table_name = 'product_category_associations'

  audited associated_with: :product, only: %i(category_id), on: %i(create destroy)

  belongs_to :product,
             inverse_of: :category_associations,
             counter_cache: :categories_count

  belongs_to :category,
             class_name: 'Products::Category',
             inverse_of: :category_associations,
             counter_cache: :products_count
end
