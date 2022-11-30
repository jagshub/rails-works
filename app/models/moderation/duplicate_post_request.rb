# frozen_string_literal: true

# == Schema Information
#
# Table name: moderation_duplicate_post_requests
#
#  id          :bigint(8)        not null, primary key
#  post_id     :bigint(8)        not null
#  url         :string           not null
#  reason      :string           not null
#  approved_at :datetime
#  user_id     :bigint(8)        not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_moderation_duplicate_post_requests_on_post_id  (post_id)
#  index_moderation_duplicate_post_requests_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (user_id => users.id)
#

class Moderation::DuplicatePostRequest < ApplicationRecord
  include Namespaceable

  belongs_to :post, inverse_of: :moderation_duplicate_post_requests
  belongs_to :user, inverse_of: :moderation_duplicate_post_requests

  def approve!
    update! approved_at: DateTime.current
  end
end
