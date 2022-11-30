# frozen_string_literal: true

# == Schema Information
#
# Table name: collection_post_associations
#
#  id            :integer          not null, primary key
#  collection_id :integer          not null
#  post_id       :integer          not null
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_collection_post_associations_on_collection_id_and_post_id  (collection_id,post_id) UNIQUE
#  index_collection_post_associations_on_post_id                    (post_id)
#

class CollectionPostAssociation < ApplicationRecord
  include SlateFieldOverride

  belongs_to :collection, touch: true
  belongs_to :post, -> { visible }, touch: true

  validates :collection_id, uniqueness: { scope: :post_id, message: 'features one post multiple times' }

  scope :with_preloads, -> { preload preload_attributes }
  scope :by_date, -> { order(arel_table[:created_at].desc) }
  scope :order_by_credible_votes, -> { joins(:post).order('posts.credible_votes_count DESC') }

  after_commit :update_collection_new_post_added, on: :create

  delegate :name, to: :collection, prefix: true

  def cache_key
    "#{ super }/#{ post.cache_key }"
  end

  private

  def update_collection_new_post_added
    collection.new_post_added!
  end
end
