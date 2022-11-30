# frozen_string_literal: true

# == Schema Information
#
# Table name: product_request_topic_associations
#
#  id                 :integer          not null, primary key
#  product_request_id :integer          not null
#  topic_id           :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  product_request_topic_associations_product_request_topic  (product_request_id,topic_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (product_request_id => product_requests.id)
#  fk_rails_...  (topic_id => topics.id)
#

class ProductRequestTopicAssociation < ApplicationRecord
  belongs_to :product_request, inverse_of: :product_request_topic_associations
  belongs_to :topic, inverse_of: :product_request_topic_associations

  validates :topic_id, uniqueness: { scope: :product_request_id }

  attr_readonly :product_request_id, :topic_id
end
