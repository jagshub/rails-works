# frozen_string_literal: true

# == Schema Information
#
# Table name: product_topic_associations
#
#  id         :bigint(8)        not null, primary key
#  product_id :bigint(8)        not null
#  topic_id   :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_product_topic_associations_on_product_id_and_topic_id  (product_id,topic_id) UNIQUE
#  index_product_topic_associations_on_topic_id                 (topic_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (topic_id => topics.id)
#
class ProductTopicAssociation < ApplicationRecord
  belongs_to :topic
  belongs_to :product, touch: true, inverse_of: :product_topic_associations

  validates :topic_id, uniqueness: { scope: :product_id }
end
