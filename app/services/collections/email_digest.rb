# frozen_string_literal: true

class Collections::EmailDigest
  attr_reader :user, :email, :user_id

  def initialize(user_id, email)
    @user_id = user_id
    @email = email
    @user = User.find(user_id) if user_id.present?
  end

  def disabled?
    return true if user_email.blank?

    user.present? && !send_collection_digest_email?
  end

  def user_email
    email || user.try(:email)
  end

  def collections
    @collections ||= find_collections
  end

  def collections?
    collections.present?
  end

  def recommended_collections
    @recommended_collections ||= find_recommended_collections
  end

  private

  def find_collections
    scope = Collection.with_recently_added_posts.joins(:subscriptions)

    scope = if user_id.present?
              scope.where('collection_subscriptions.user_id = ?', user_id)
            else
              scope.where('collection_subscriptions.email = ?', email)
            end

    scope.order(subscriber_count: :desc).reject do |collection|
      collection.recently_added_posts.count == 0
    end
  end

  def send_collection_digest_email?
    user.send_collection_digest_email
  end

  def find_recommended_collections
    scope = Collection.featured.joins(:subscriptions)

    scope = if user_id.present?
              scope.where('collection_subscriptions.user_id != ?', user_id)
            else
              scope.where('collection_subscriptions.email != ?', email)
            end

    # Note(Mike Coutermarsh): using `sample` rather than `RANDOM()` saves us about 150ms
    scope.limit(100).sample(2)
  end
end
