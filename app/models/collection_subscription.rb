# frozen_string_literal: true

# == Schema Information
#
# Table name: collection_subscriptions
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  collection_id :integer          not null
#  email         :string
#  state         :integer          default("subscribed"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_collection_subscriptions_on_collection_id              (collection_id)
#  index_collection_subscriptions_on_user_id_and_collection_id  (user_id,collection_id) UNIQUE
#  index_collection_subscriptions_on_user_id_and_state          (user_id,state)
#

class CollectionSubscription < ApplicationRecord
  belongs_to :collection
  belongs_to :user, optional: true

  validates :state, presence: true

  validates :user_id, allow_blank: true, uniqueness: { message: 'already subscribed', scope: :collection_id }
  validates :email, email_format: true, allow_blank: true

  validate :email_or_user_present

  enum state: { subscribed: 0, unsubscribed: 100 }

  after_save :refresh_counter

  scope :active, -> { where(state: states[:subscribed]) }
  scope :with_user, -> { where.not(user_id: nil) }

  class << self
    # TODO(DZ): Combine into subscriptions
    def subscribe(collection, user: nil, email: nil)
      HandleRaceCondition.call do
        subscription = collection.subscriptions.find_or_initialize_by(user: user, email: email)
        subscription.subscribed!
        subscription
      end
    end

    def unsubscribe(collection, user: nil, email: nil)
      attributes = user.present? ? { user: user } : { email: email }

      HandleRaceCondition.call do
        subscription = collection.subscriptions.find_or_initialize_by(attributes)
        subscription.unsubscribed!
        subscription
      end
    end

    def subscribed?(collection, user: nil, email: nil)
      subscription = collection.subscriptions.find_by(user: user, email: email)
      subscription&.subscribed?
    end

    def unsubscribe_all(email:)
      where(email: email).active.update_all state: states['unsubscribed']
    end
  end

  private

  def refresh_counter
    # ToDo(Rahul): Revert the below line "&." after the sidekiq retry passes https://sentry.io/producthuntcom/production-sidekiq/issues/844926590/?query=is%3Aunresolved
    collection&.refresh_subscriber_count

    user.refresh_subscribed_collections_count if user.present?
  end

  def email_or_user_present
    return if user_id.present? || email.present?

    errors.add(:base, 'either user or email is required')
  end
end
