# frozen_string_literal: true

# == Schema Information
#
# Table name: post_topic_associations
#
#  id         :integer          not null, primary key
#  post_id    :integer          not null
#  topic_id   :integer          not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_post_topic_associations_on_post_id_and_topic_id  (post_id,topic_id) UNIQUE
#  index_post_topic_associations_on_topic_id_and_post_id  (topic_id,post_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (topic_id => topics.id)
#  fk_rails_...  (user_id => users.id)
#

class PostTopicAssociation < ApplicationRecord
  belongs_to :topic
  belongs_to :post, touch: true
  belongs_to :user, optional: true

  validates :topic_id, uniqueness: { scope: :post_id }

  after_commit :refresh_counters, :sync_product_topics, only: %i(create destroy)

  def refresh_counters
    topic.refresh_counters([:posts])
  end

  private

  def sync_product_topics
    post.new_product&.sync_topic_associations
  end
end
