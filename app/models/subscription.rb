# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id            :integer          not null, primary key
#  subscriber_id :integer          not null
#  subject_id    :integer
#  subject_type  :string
#  state         :integer          default("subscribed"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  source        :string
#  muted         :boolean          default(FALSE), not null
#
# Indexes
#
#  index_subscriptions_on_created_at                             (created_at)
#  index_subscriptions_on_subject_and_subscriber                 (state,subject_type,subject_id,subscriber_id) UNIQUE
#  index_subscriptions_on_subject_and_subscriber_reverse         (state,subject_type,subscriber_id,subject_id) UNIQUE
#  index_subscriptions_on_subject_id_and_subject_type_and_state  (subject_id,subject_type,state)
#  index_subscriptions_on_subject_type_and_subscriber_id         (subject_type,subscriber_id)
#  index_subscriptions_on_subscriber_id_and_subject_id           (subscriber_id,subject_id)
#

class Subscription < ApplicationRecord
  SUBJECTS = [
    Discussion::Thread,
    GoldenKitty::Edition,
    Post,
    Product,
    Topic,
    Upcoming::Event,
  ].freeze

  # NOTE(DZ): Goal is deprecated and is included here for backwards compatibility
  belongs_to_polymorphic :subject, allowed_classes: SUBJECTS + [Goal], inverse_of: :subscriptions
  belongs_to :subscriber, inverse_of: :subscriptions

  scope :active, -> { where(state: states[:subscribed]) }
  scope :for_topics, -> { where(subject_type: Topic.name) }
  scope :for_posts, -> { where(subject_type: Post.name) }
  scope :for_discussions, -> { where(subject_type: Discussion::Thread.name) }
  scope :for_products, -> { where(subject_type: Product.name) }

  validates :subject_id, uniqueness: { scope: %i(subscriber_id subject_type) }

  enum state: { subscribed: 0, unsubscribed: 100 }

  after_create :refresh_counters
  after_update :refresh_counters
  after_destroy :refresh_counters

  private

  # Note(Rahul): followers_count is subscribers with user count
  #              subscribers_count is the total subscribers count
  def refresh_counters
    %i(followers subscribers).each do |counter_name|
      refresh_method_name = "refresh_#{ counter_name }_count"

      if subject.is_a? Topic
        # Note(AR): Topics take lots of time to update -- do it in the background
        subject.public_send("async_#{ refresh_method_name }")
      elsif subject.respond_to? refresh_method_name
        subject.public_send(refresh_method_name)
      end
    end
  end
end
