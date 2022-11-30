# frozen_string_literal: true

# == Schema Information
#
# Table name: product_post_associations
#
#  id         :bigint(8)        not null, primary key
#  product_id :bigint(8)        not null
#  post_id    :bigint(8)        not null
#  kind       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  source     :string           not null
#
# Indexes
#
#  index_product_post_associations_on_post_id     (post_id) UNIQUE
#  index_product_post_associations_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (product_id => products.id)
#

class Products::PostAssociation < ApplicationRecord
  self.table_name = 'product_post_associations'

  audited associated_with: :product, only: %i(kind post_id)

  after_commit :refresh_counter, :sync_product_topics, only: %i(create destroy)
  after_commit :refresh_product_state

  belongs_to :product,
             class_name: 'Product',
             inverse_of: :post_associations

  belongs_to :post,
             class_name: 'Post',
             inverse_of: :product_association

  enum kind: {
    version: 'version',
  }

  enum source: {
    admin: 'admin',
    moderation: 'moderation',
    merge: 'merge',
    data_migration: 'data_migration',
    post_create: 'post_create',
    post_update: 'post_update',
  }, _prefix: true

  attr_readonly :product_id, :post_id

  private

  def refresh_counter
    product.refresh_posts_count
  end

  # Note(Rahul): When product_id get's updated, update both
  #              old & new product state
  def refresh_product_state
    product_ids = (saved_changes['product_id'] || []).compact

    if product_ids.length > 1
      Product.where(id: product_ids).find_each do |p|
        Products.set_product_state(p)
      end
    else
      Products.set_product_state(product)
    end
  end

  def sync_product_topics
    product.sync_topic_associations
  end
end
