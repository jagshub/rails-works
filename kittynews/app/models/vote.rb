# == Schema Information
#
# Table name: votes
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  post_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_votes_on_post_id              (post_id)
#  index_votes_on_post_id_and_user_id  (post_id,user_id) UNIQUE
#  index_votes_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (user_id => users.id)
#
class Vote < ApplicationRecord
  belongs_to :user, required: true, inverse_of: :votes
  belongs_to :post, required: true, inverse_of: :votes, counter_cache: true

  validates_uniqueness_of :post_id, scope: :user_id, message: "already voted"
end
