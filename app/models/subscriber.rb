# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications_subscribers
#
#  id                              :integer          not null, primary key
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  user_id                         :integer
#  browser_push_token              :string
#  mobile_push_token               :string
#  desktop_push_token              :string
#  options                         :jsonb            not null
#  email_confirmed                 :boolean          default(FALSE)
#  email                           :citext
#  verification_token              :string
#  verification_token_generated_at :datetime
#  grandfathered_verification      :boolean
#  first_time_newsletter_recipient :boolean          default(TRUE)
#
# Indexes
#
#  index_notifications_subscribers_on_browser_push_token  (browser_push_token) UNIQUE
#  index_notifications_subscribers_on_desktop_push_token  (desktop_push_token) UNIQUE
#  index_notifications_subscribers_on_email               (email) UNIQUE
#  index_notifications_subscribers_on_hashed_email        (md5(lower((email)::text)))
#  index_notifications_subscribers_on_mobile_push_token   (mobile_push_token) UNIQUE
#  index_notifications_subscribers_on_user_id             (user_id) UNIQUE
#  index_notifications_subscribers_on_verification_token  (verification_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Subscriber < ApplicationRecord
  include Storext.model

  # Note(andreasklinger): see monkey_patches/jsonb_monkey_patch.rb
  include JsonbTypeMonkeyPatch[:options, :bar]

  # Note(andreasklinger): table has legacy name
  self.table_name = 'notifications_subscribers'

  belongs_to :user, optional: true

  has_many :all_subscriptions,
           class_name: 'Subscription',
           foreign_key: :subscriber_id,
           dependent: :delete_all,
           inverse_of: :subscriber
  has_many :subscriptions, -> { active }, foreign_key: :subscriber_id, inverse_of: :subscriber
  has_many :notification_logs, dependent: :destroy
  has_many :newsletter_events, inverse_of: :subscriber, dependent: :nullify
  delegate :name, to: :user, allow_nil: true

  validates :user_id, allow_nil: true, uniqueness: true
  validates :browser_push_token, allow_nil: true, uniqueness: true
  validates :desktop_push_token, allow_nil: true, uniqueness: true
  validates :mobile_push_token, allow_nil: true, uniqueness: true
  validates :email, email_format: true, allow_blank: true, uniqueness: true
  validates :newsletter_subscription, inclusion: { in: Newsletter::Subscriptions::STATES }

  validate :validate_presence_of_some_token_or_user_id

  before_validation :normalize_email

  scope :with_email, -> { where.not(email: nil) }
  scope :with_email_confirmed, -> { where(email_confirmed: true).with_email }
  scope :with_maker_digest_subscription, -> { where.not('options @> ?', { maker_digest_subscription: false }.to_json) }
  scope :with_job_digest_subscription, -> { where('options @> ?', { jobs_newsletter_subscription: Jobs::Newsletter::Subscriptions::SUBSCRIBED }.to_json) }
  scope :with_stories_newsletter_subscription, -> { where('options @> ?', { stories_newsletter_subscription: Anthologies::Stories::Newsletter::Subscriptions::SUBSCRIBED }.to_json) }
  scope :with_newsletter_subscription, ->(subscription) { where('options @> ?', { newsletter_subscription: subscription }.to_json) }
  scope :with_user, -> { where.not(user_id: nil) }
  scope :without_user, -> { where(user_id: nil) }
  scope :unverified, -> { where(email_confirmed: false) }

  store_attributes :options do
    deals_newsletter_subscription String, default: 'never_subscribed'
    jobs_newsletter_subscription String, default: Jobs::Newsletter::Subscriptions::NEVER_SUBSCRIBED
    jobs_newsletter_subscription_locations Array[String], default: nil
    jobs_newsletter_subscription_roles Array[String], default: nil
    jobs_newsletter_subscription_skills Array[String], default: nil
    maker_digest_subscription Boolean, default: true
    newsletter_subscription String, default: Newsletter::Subscriptions::UNSUBSCRIBED
    stories_newsletter_subscription String, default: Anthologies::Stories::Newsletter::Subscriptions::UNSUBSCRIBED

    slack_access_token String, default: nil
    slack_scope String, default: nil
    slack_user_id String, default: nil
    slack_team_name String, default: nil
    slack_team_id String, default: nil
    slack_webhook_channel String, default: nil
    slack_webhook_channe_id String, default: nil
    slack_webhook_configuration_url String, default: nil
    slack_webhook_url String, default: nil
    slack_active Boolean, default: false
  end

  class << self
    def get_ids_by(user_ids: [])
      # find existing subscriptions
      existing_subscriptions = where(user_id: user_ids)

      # create subscriptions for those users that don't have one yet
      missing_user_ids = user_ids - existing_subscriptions.map(&:user_id)
      new_subscriber_ids = User.where(id: missing_user_ids).map { |user| for_user(user).id }

      existing_subscriptions.map(&:id) + new_subscriber_ids
    end

    def for_user(user)
      HandleRaceCondition.call do
        find_by(user: user) || user.create_subscriber!
      end
    end

    def email_available?(email, for_user: nil)
      scope = where.not(user_id: nil)
      scope = where.not(user_id: for_user.id) if for_user
      !scope.where(email: email).exists?
    end

    def find_by_user_or_email(user:, email:)
      return find_by(user_id: user.id) if user.present?
      return find_by_email(email) if email.present?
    end

    def find_by_email(email)
      return if email.blank?

      find_by(email: email)
    end

    def find_by_token(token)
      return if token.blank?

      find_by('browser_push_token = :token OR mobile_push_token = :token OR desktop_push_token = :token', token: token)
    end
  end

  TOKENS = %i(browser_push_token mobile_push_token desktop_push_token slack_webhook_url email).freeze

  def no_tokens?
    TOKENS.all? { |token| self[token].blank? }
  end

  def clear_tokens
    self.attributes = TOKENS.map { |token| [token, nil] }.to_h
  end

  def flipper_id
    id
  end

  def subscribed_to_newsletter?
    newsletter_subscription != Newsletter::Subscriptions::UNSUBSCRIBED
  end

  def subscribed_to_jobs_newsletter?
    jobs_newsletter_subscription == Jobs::Newsletter::Subscriptions::SUBSCRIBED
  end

  def subscribed_to_stories_newsletter?
    stories_newsletter_subscription == Anthologies::Stories::Newsletter::Subscriptions::SUBSCRIBED
  end

  def verification_token_valid?
    verification_token.present? &&
      verification_token_generated_at.present? &&
      verification_token_generated_at >= 24.hours.ago
  end

  def can_change_email?
    !verification_token_valid?
  end

  private

  def normalize_email
    self.email = email.presence && email.downcase
  end

  # Note(andreasklinger): Avoid empty subscribers that neither relate to users nor guests
  def validate_presence_of_some_token_or_user_id
    return unless no_tokens? && user_id.blank?

    errors.add(:base, 'At least a user or a token should be present')
  end
end
