# frozen_string_literal: true

# == Schema Information
#
# Table name: stream_feed_items
#
#  id                 :bigint(8)        not null, primary key
#  verb               :string           not null
#  actor_ids          :integer          default([]), not null, is an Array
#  action_objects     :string           default([]), not null, is an Array
#  receiver_id        :bigint(8)        not null
#  target_type        :string           not null
#  target_id          :bigint(8)        not null
#  seen_at            :datetime
#  last_occurrence_at :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  data               :jsonb
#  connecting_text    :string           not null
#  interactions       :jsonb
#
# Indexes
#
#  index_stream_feed_items_on_action_objects             (action_objects) USING gin
#  index_stream_feed_items_on_last_occurrence_at         (last_occurrence_at)
#  index_stream_feed_items_on_receiver_id                (receiver_id)
#  index_stream_feed_items_on_seen_at                    (seen_at)
#  index_stream_feed_items_on_target_type_and_target_id  (target_type,target_id)
#  index_stream_feed_items_on_verb                       (verb)
#
# Foreign Keys
#
#  fk_rails_...  (receiver_id => users.id)
#

class Stream::FeedItem < ApplicationRecord
  include Namespaceable

  HasTimeAsFlag.define self, :seen, enable: :mark_seen

  belongs_to :receiver, class_name: 'User', inverse_of: :feed_items
  belongs_to :target, polymorphic: true

  validates :verb, presence: true
  validates :last_occurrence_at, presence: true

  scope :visible, -> { where.not(data: nil) }
  scope :for_user, ->(user) { where(receiver: user) }
  scope :by_priority, -> { order(seen_at: :desc, last_occurrence_at: :desc) }
  scope :for_target, ->(target) { where(target: target) }
  scope :for_action_object, ->(object) { where('action_objects @> ?', "{#{ object.class.name }_#{ object.id }}") }
  scope :for_connecting_text, ->(connecting_text) { where(connecting_text: connecting_text) }

  class << self
    def graphql_type
      Graph::Types::Notifications::FeedItemType
    end

    def graph_v2_internal_type
      ::Mobile::Graph::Types::ActivityItemType
    end
  end

  def actors
    @actors ||= User.where(id: actor_ids).to_a
  end

  VERB_TO_EMOJI = {
    'change-log' => '🆕',
    'comment' => '💬',
    'discussion-start' => '💬',
    'maker-group-member-accept' => '👏',
    'maker-festival-register' => '👀',
    'post-hunt' => '🚀',
    'post-launch' => '🚀',
    'product-post-launch' => '🚀',
    'post-maker-list' => '👏',
    'upcoming-page-launch' => '🚀',
    'upcoming-page-subscribe' => '💌',
    'user-follow' => '🔥',
    'upvote' => '🔼',
    'review' => '💭',
    'user-badge-awarded' => '🏅',
  }.freeze

  MENTIONED_YOU_IN = 'mentioned you in'
  COMMENTED_ON_YOUR = 'commented on your'
  COMMENTED_ON = 'commented on'
  REPLIED_TO_YOUR_REVIEW = 'replied to your review of'
  REVIEWED = 'reviewed'

  def emoji
    VERB_TO_EMOJI[verb]
  end
end
