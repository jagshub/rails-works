# frozen_string_literal: true

# == Schema Information
#
# Table name: product_categories
#
#  id                        :bigint(8)        not null, primary key
#  name                      :string           not null
#  slug                      :string           not null
#  description               :string
#  parent_id                 :bigint(8)
#  products_count            :integer          default(0), not null
#  children_categories_count :integer          default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_product_categories_on_parent_id  (parent_id)
#
class Products::Category < ApplicationRecord
  self.table_name = 'product_categories'

  extension(
    Search.searchable_association,
    association: :products,
    if: :saved_change_to_name?,
  )

  include Sluggable

  sluggable

  belongs_to :parent,
             class_name: 'Products::Category',
             inverse_of: :children,
             counter_cache: :children_categories_count,
             optional: true

  has_many :children,
           class_name: 'Products::Category',
           inverse_of: :parent,
           dependent: :nullify

  has_many :category_associations,
           class_name: 'Products::CategoryAssociation',
           inverse_of: :category,
           dependent: :destroy

  has_many :products, through: :category_associations

  # NOTE(DZ): Allows for manual slug input
  def should_generate_new_friendly_id?
    slug.blank?
  end
end
