# frozen_string_literal: true

# == Schema Information
#
# Table name: product_request_related_product_request_associations
#
#  id                         :integer          not null, primary key
#  product_request_id         :integer          not null
#  related_product_request_id :integer          not null
#  user_id                    :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_related_product_requests_on_product_requests         (product_request_id,related_product_request_id) UNIQUE
#  index_related_product_requests_on_related_product_request  (related_product_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_request_id => product_requests.id)
#  fk_rails_...  (related_product_request_id => product_requests.id)
#

class ProductRequestRelatedProductRequestAssociation < ApplicationRecord
  belongs_to :product_request, touch: true
  belongs_to :related_product_request, class_name: 'ProductRequest', touch: true

  validates :related_product_request_id, uniqueness: { scope: :product_request_id }

  validate :ensure_product_request_isnt_related_to_self

  after_commit :refresh_counters, only: %i(create destroy)

  scope :by_product_request_ids, ->(id:, related_product_request_id:) { where(arel_table[:product_request_id].eq(id).and(arel_table[:related_product_request_id].eq(related_product_request_id)).or(arel_table[:product_request_id].eq(related_product_request_id).and(arel_table[:related_product_request_id].eq(id)))) }

  private

  def ensure_product_request_isnt_related_to_self
    return if product_request.nil? || related_product_request.nil?

    errors.add(:related_product_request, "can't be same as product request") if product_request == related_product_request
  end

  def refresh_counters
    product_request.refresh_related_product_requests_count
  end
end
