# frozen_string_literal: true

# == Schema Information
#
# Table name: collection_topic_associations
#
#  id            :integer          not null, primary key
#  collection_id :integer          not null
#  topic_id      :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  collection_topic_associations_collection_topic  (collection_id,topic_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (collection_id => collections.id)
#  fk_rails_...  (topic_id => topics.id)
#

class CollectionTopicAssociation < ApplicationRecord
  belongs_to :collection, inverse_of: :collection_topic_associations
  belongs_to :topic, inverse_of: :collection_topic_associations

  validates :topic_id, uniqueness: { scope: :collection_id }

  attr_readonly :collection_id, :topic_id
end
