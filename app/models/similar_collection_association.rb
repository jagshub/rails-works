# frozen_string_literal: true

# == Schema Information
#
# Table name: similar_collection_associations
#
#  id                    :integer          not null, primary key
#  collection_id         :integer          not null
#  similar_collection_id :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_similar_coll_associations_on_coll_id_and_similar_coll_id  (collection_id,similar_collection_id) UNIQUE
#

class SimilarCollectionAssociation < ApplicationRecord
  belongs_to :collection
  belongs_to :similar_collection, class_name: 'Collection'

  validates :similar_collection_id, uniqueness: { scope: :collection_id, message: 'collection already added as similar' }

  validate :ensure_collection_isnt_similar_to_self

  private

  def ensure_collection_isnt_similar_to_self
    return if collection.blank? || similar_collection.blank?

    errors.add(:similar_collection, "can't be same as collection") if collection == similar_collection
  end
end
