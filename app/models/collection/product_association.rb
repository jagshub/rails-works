# frozen_string_literal: true

# == Schema Information
#
# Table name: collection_product_associations
#
#  id            :bigint(8)        not null, primary key
#  collection_id :bigint(8)        not null
#  product_id    :bigint(8)        not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_collection_product_assoc_on_collection_id_and_product_id  (collection_id,product_id) UNIQUE
#  index_collection_product_associations_on_product_id             (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (collection_id => collections.id)
#  fk_rails_...  (product_id => products.id)
#
class Collection::ProductAssociation < ApplicationRecord
  include Namespaceable

  belongs_to :collection, inverse_of: :collection_product_associations, counter_cache: :products_count
  belongs_to :product, inverse_of: :collection_product_associations

  after_commit :update_collection_product_added, on: :create

  private

  def update_collection_product_added
    collection.product_added
  end
end
