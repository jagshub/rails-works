# frozen_string_literal: true

# == Schema Information
#
# Table name: recommendations
#
#  id                     :integer          not null, primary key
#  recommended_product_id :integer          not null
#  user_id                :integer          not null
#  body                   :text             not null
#  votes_count            :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  credible_votes_count   :integer          default(0), not null
#  edited_at              :datetime
#  comments_count         :integer          default(0), not null
#  disclosed              :boolean          default(FALSE)
#  highlighted            :boolean          default(FALSE)
#  user_flags_count       :integer          default(0)
#
# Indexes
#
#  index_recommendations_on_comments_count          (comments_count)
#  index_recommendations_on_credible_votes_count    (credible_votes_count)
#  index_recommendations_on_recommended_product_id  (recommended_product_id)
#  index_recommendations_on_user_id                 (user_id)
#

class Recommendation < ApplicationRecord
  include Votable
  include Commentable
  include UserFlaggable

  belongs_to :recommended_product, touch: true
  belongs_to :user, counter_cache: true

  validates :body, presence: true

  after_commit :refresh_counters, only: %i(create destroy)
  after_destroy :destroy_recommended_product_without_recommendations

  scope :by_date, ->(order = :asc) { order(arel_table[:created_at].public_send(order)) }
  scope :helpful, -> { where(arel_table[:credible_votes_count].gt(2)) }

  delegate :product_request, to: :recommended_product

  def to_param
    "#{ id }-by-#{ user.name.parameterize }"
  end

  private

  def destroy_recommended_product_without_recommendations
    recommended_product.destroy unless recommended_product.recommendations.any?
  end

  def refresh_counters
    user.refresh_helpful_recommendations_count
  end
end
