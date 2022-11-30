# frozen_string_literal: true

# == Schema Information
#
# Table name: user_follow_product_request_associations
#
#  id                 :integer          not null, primary key
#  user_id            :integer          not null
#  product_request_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  source_id          :integer
#
# Indexes
#
#  index_user_follow_product_requests_on_product_request           (product_request_id)
#  index_user_follow_product_requests_on_user_and_product_request  (user_id,product_request_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (product_request_id => product_requests.id)
#  fk_rails_...  (user_id => users.id)
#

class UserFollowProductRequestAssociation < ApplicationRecord
  belongs_to :product_request
  belongs_to :user

  validates :product_request_id, uniqueness: { scope: :user_id }

  after_commit :refresh_counters, only: %i(create destroy)

  private

  def refresh_counters
    product_request.refresh_followers_count
    user.refresh_user_follow_product_request_associations_count
  end
end
