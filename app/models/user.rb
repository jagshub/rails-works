# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                                             :integer          not null, primary key
#  name                                           :string(255)
#  username                                       :string(255)
#  twitter_uid                                    :string(255)
#  image                                          :text
#  headline                                       :string(255)
#  created_at                                     :datetime
#  updated_at                                     :datetime
#  login_count                                    :integer          default(1), not null
#  role                                           :integer          default("user")
#  invited_by_id                                  :integer
#  via_application_id                             :integer
#  twitter_access_token                           :text
#  twitter_access_secret                          :text
#  last_twitter_sync_at                           :datetime
#  follower_count                                 :integer          default(0), not null
#  friend_count                                   :integer          default(0), not null
#  website_url                                    :string(255)
#  last_twitter_sync_error                        :text
#  twitter_verified                               :boolean          default(FALSE), not null
#  avatar                                         :text
#  beta_tester                                    :boolean          default(FALSE), not null
#  twitter_username                               :text
#  facebook_uid                                   :bigint(8)
#  trashed_at                                     :datetime
#  last_friend_sync_at                            :datetime
#  notification_preferences                       :jsonb            not null
#  header_uuid                                    :string
#  private_profile                                :boolean          default(FALSE)
#  helpful_recommendations_count                  :integer          default(0), not null
#  angellist_uid                                  :string
#  product_requests_count                         :integer          default(0), not null
#  recommendations_count                          :integer          default(0), not null
#  user_follow_product_request_associations_count :integer          default(0), not null
#  hide_hiring_badge                              :boolean          default(FALSE), not null
#  goals_count                                    :integer          default(0), not null
#  completed_goals_count                          :integer          default(0), not null
#  maker_group_memberships_count                  :integer          default(0), not null
#  confirmed_age                                  :boolean          default(FALSE), not null
#  receive_direct_messages                        :boolean          default(TRUE), not null
#  chat_preferences                               :integer          default(100), not null
#  location                                       :string
#  job_role                                       :string
#  skills                                         :string           default([]), is an Array
#  job_search                                     :boolean          default(FALSE)
#  google_uid                                     :string
#  role_reason                                    :integer
#  country                                        :string
#  state                                          :string
#  city                                           :string
#  job_preference                                 :jsonb            not null
#  default_goal_session_duration                  :integer          default("25m"), not null
#  notification_feed_items_unread_count           :integer
#  notification_feed_last_seen_at                 :datetime
#  last_active_at                                 :date
#  avatar_uploaded_at                             :datetime
#  karma_points                                   :integer
#  karma_points_updated_at                        :datetime
#  user_flags_count                               :integer          default(0)
#  welcome_email_sent                             :boolean
#  comments_count                                 :integer          default(0), not null
#  posts_count                                    :integer          default(0), not null
#  product_makers_count                           :integer          default(0), not null
#  last_user_agent                                :string
#  votes_count                                    :integer          default(0), not null
#  collections_count                              :integer          default(0), not null
#  subscribed_collections_count                   :integer          default(0), not null
#  upcoming_pages_count                           :integer          default(0), not null
#  subscribed_upcoming_pages_count                :integer          default(0), not null
#  apple_uid                                      :string
#  ambassador                                     :boolean
#  badges_count                                   :integer          default(0), not null
#  default_collection_id                          :bigint(8)
#  badges_unique_count                            :integer          default(0), not null
#  mobile_devices_count                           :integer          default(0), not null
#  about                                          :text
#  activity_events_count                          :integer
#  last_active_ip                                 :string
#
# Indexes
#
#  index_users_on_ambassador             (ambassador)
#  index_users_on_angellist_uid          (angellist_uid) UNIQUE
#  index_users_on_apple_uid              (apple_uid) UNIQUE
#  index_users_on_default_collection_id  (default_collection_id)
#  index_users_on_follower_count         (follower_count)
#  index_users_on_google_uid             (google_uid) UNIQUE
#  index_users_on_role                   (role)
#  index_users_on_username               (username) UNIQUE
#  users_facebook_uid_idx                (facebook_uid) UNIQUE WHERE (trashed_at IS NULL)
#  users_on_name_fast                    (name) USING gin
#  users_on_username_fast                (username) USING gin
#  users_twitter_uid_idx                 (twitter_uid) UNIQUE WHERE (trashed_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (default_collection_id => collections.id)
#

class User < ApplicationRecord
  MAX_LENGTH_NAME = 40
  MAX_LENGTH_HEADLINE = 40
  MAX_LENGTH_ABOUT = 800

  extension HandleInvalidUnicode, %i(name username headline about)

  extension(
    Search.searchable,
    only: :searchable,
    includes: :links,
    if: :should_reindex_search?,
  )

  extension(
    Search.searchable_association,
    # NOTE(DZ): `products` in this case are posts (as makers)
    association: %i(
      collections
      discussion_threads
      posts
      products
      stories
      upcoming_pages
    ),
    if: :reindex_associations?,
  )

  include Trashable
  include RandomOrder
  include ExplicitCounterCache
  include Storext.model
  include UserFlaggable

  # Note(andreasklinger): see monkey_patches/jsonb_monkey_patch.rb
  include JsonbTypeMonkeyPatch[:notification_preferences]

  include Uploadable
  uploadable :header

  audited only: %i(apple_uid facebook_uid google_uid twitter_uid role role_reason name username)

  belongs_to :default_collection, class_name: 'Collection', optional: true
  has_many :product_skip_review_suggestions, class_name: '::Products::SkipReviewSuggestion', dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :flags, dependent: :destroy
  has_many :access_tokens, dependent: :destroy
  has_many :oauth_applications, class_name: 'OAuth::Application', as: :owner
  has_many :oauth_requests, class_name: 'OAuth::Request', inverse_of: :user, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :dismissables, dependent: :destroy
  has_many :product_makers, dependent: :destroy
  has_many :maker_suggestions, dependent: :destroy, foreign_key: :maker_id
  has_many :products, foreign_key: 'post_id', through: :product_makers, source: :post
  has_many :product_screenshots, class_name: 'Products::Screenshot', dependent: :nullify
  # NOTE(TE): product-name-refactor (in-line with Post.new_product)
  has_many :new_product_associations, through: :products, source: :product_association
  has_many :new_products, through: :new_product_associations, source: :product
  has_many :moderation_logs, dependent: :destroy, as: :reference
  has_many :moderation_locks, dependent: :destroy
  has_many :moderation_skips, dependent: :destroy
  has_many :product_requests, dependent: :destroy
  has_many :recommendations, dependent: :destroy
  has_many :user_follow_product_request_associations, dependent: :destroy
  has_many :file_exports, dependent: :destroy, inverse_of: :user
  has_many :moderation_duplicate_post_requests, class_name: '::Moderation::DuplicatePostRequest', inverse_of: :user, dependent: :destroy
  has_many :link_trackers, dependent: :delete_all
  has_many :promoted_analytics, dependent: :delete_all
  has_many :stories, class_name: 'Anthologies::Story', dependent: :destroy, inverse_of: :author
  has_many :multi_factor_tokens, foreign_key: :user_id, dependent: :destroy, inverse_of: :user
  has_many :media, inverse_of: :user, dependent: :nullify

  has_many :goals, inverse_of: :user, dependent: :destroy
  has_many :all_maker_group_memberships, class_name: 'MakerGroupMember', inverse_of: :user, dependent: :destroy
  has_many :maker_group_memberships, -> { accessible.accepted.by_activity }, class_name: 'MakerGroupMember', inverse_of: :user
  has_many :maker_groups, -> { by_kind }, through: :maker_group_memberships, source: :group

  has_many :onboardings, inverse_of: :user, dependent: :destroy
  has_many :onboarding_reasons, inverse_of: :user, dependent: :destroy
  has_many :onboarding_tasks, inverse_of: :user, dependent: :destroy

  has_many :registration_reasons, class_name: 'Users::RegistrationReason', inverse_of: :user, dependent: :destroy

  has_many :votes, dependent: :destroy

  has_many :card_update_logs, class_name: 'Payment::CardUpdateLog', inverse_of: :user, dependent: :destroy

  has_many :visit_streaks, inverse_of: :user, dependent: :delete_all

  has_many :team_invites, class_name: 'Team::Invite', inverse_of: :user, dependent: :destroy
  has_many :sent_team_invites, class_name: 'Team::Invite', foreign_key: :referrer_id, inverse_of: :user, dependent: :destroy

  has_many :team_requests, class_name: 'Team::Request', inverse_of: :user, dependent: :destroy
  has_many :moderated_team_requests, class_name: 'Team::Request', foreign_key: :status_changed_by_id, inverse_of: :status_changed_by, dependent: :nullify

  has_many :team_memberships, class_name: 'Team::Member', inverse_of: :user, dependent: :destroy

  # NOTE(rstankov): Adds vote relationships like: post_votes, voted_posts
  Votable.add_many_votes self, class_names: ::Vote::SUBJECT_TYPES

  belongs_to :invited_by, class_name: 'User', foreign_key: :invited_by_id, optional: true

  has_many :invited_users, class_name: 'User', foreign_key: :invited_by_id

  has_many :mobile_devices, class_name: 'Mobile::Device', inverse_of: :user, counter_cache: true, dependent: :destroy

  has_many :user_friend_associations, foreign_key: :followed_by_user_id, dependent: :destroy
  has_many :friends, through: :user_friend_associations, source: :following_user

  has_many :user_follower_associations, class_name: 'UserFriendAssociation',
                                        foreign_key: :following_user_id,
                                        dependent: :destroy
  has_many :followers, through: :user_follower_associations, source: :followed_by_user

  has_many :post_topic_associations, foreign_key: :user_id, dependent: :nullify
  has_many :topic_user_association, inverse_of: :topic, dependent: :delete_all

  has_many :reviews, dependent: :destroy

  has_one :subscriber, dependent: :destroy
  has_many :new_social_login_requests,
           class_name: 'Users::NewSocialLogin',
           dependent: :destroy,
           inverse_of: :user

  has_one :cookie_policy, class_name: 'CookiePolicyLog', inverse_of: :user, dependent: :destroy

  has_one :ship_account, dependent: :destroy, inverse_of: :user
  has_one :ship_lead, dependent: :destroy
  has_one :ship_subscription, dependent: :destroy, inverse_of: :user
  has_one :ship_billing_information, dependent: :destroy, inverse_of: :user
  has_one :ship_user_metadata, dependent: :destroy, inverse_of: :user
  has_one :ship_instant_access_page, through: :ship_user_metadata
  has_many :ship_contacts, inverse_of: :user, dependent: :nullify
  has_many :ship_account_member_associations, dependent: :delete_all, inverse_of: :user
  has_many :ship_tracking_identities, dependent: :destroy, inverse_of: :user

  has_one :delete_survey, class_name: 'UserDeleteSurvey', inverse_of: :user, dependent: :destroy

  has_many :subscriptions, through: :subscriber
  has_many :followed_topics, through: :subscriptions, source: :subject, source_type: 'Topic'
  has_many :followed_products, through: :subscriptions, source: :subject, source_type: 'Product'

  has_many :collection_subscriptions, dependent: :destroy
  has_many :active_collection_subscriptions, -> { active }, class_name: 'CollectionSubscription'
  has_many :subscribed_collections, through: 'active_collection_subscriptions', class_name: 'Collection', source: :collection

  has_many :upcoming_page_subscriptions, class_name: 'UpcomingPageSubscriber', through: :ship_contacts, source: :subscribers
  has_many :upcoming_pages, dependent: :destroy, inverse_of: :user
  has_many :upcoming_page_messages, dependent: :destroy, inverse_of: :user
  has_many :upcoming_page_conversation_messages, dependent: :destroy
  has_many :subscribed_upcoming_pages, -> { where('upcoming_page_subscribers.state' => UpcomingPageSubscriber.states[:confirmed]) }, class_name: 'UpcomingPage', through: :upcoming_page_subscriptions, source: :upcoming_page

  has_many :jobs, inverse_of: :user

  has_many :golden_kitty_nominations, class_name: 'GoldenKitty::Nominee', inverse_of: :user, dependent: :destroy

  has_many :payment_subscriptions, class_name: 'Payment::Subscription', inverse_of: :user

  has_many :founder_club_claims, class_name: 'FounderClub::Claim', dependent: :destroy, inverse_of: :user
  has_many :founder_club_deals, class_name: 'FounderClub::Deal', through: :founder_club_claims, source: :deal
  has_one :founder_club_access_request, class_name: 'FounderClub::AccessRequest', dependent: :destroy, inverse_of: :user
  has_many :founder_club_referrals, class_name: 'FounderClub::AccessRequest', dependent: :destroy, inverse_of: :invited_by_user, foreign_key: 'invited_by_user_id'

  has_many :makers_festival_participant, class_name: 'MakersFestival::Participant', inverse_of: :user, dependent: :destroy
  has_many :makers_festival_makers, class_name: 'MakersFestival::Maker', inverse_of: :user, dependent: :destroy

  has_many :discussion_threads, class_name: 'Discussion::Thread', inverse_of: :user, dependent: :destroy

  has_one :browser_extension_setting, class_name: 'BrowserExtension::Setting', dependent: :destroy, inverse_of: :user

  has_many :poll_answers, inverse_of: :user

  has_many :maker_activities, dependent: :delete_all

  has_many :feed_items, class_name: 'Stream::FeedItem', dependent: :delete_all, foreign_key: :receiver_id, inverse_of: :receiver

  has_many :spam_logs, class_name: 'Spam::Log', inverse_of: :user, dependent: :delete_all

  has_many :golden_kitty_people, class_name: 'GoldenKitty::Person', dependent: :delete_all, inverse_of: :user

  has_many :promoted_email_signups, class_name: 'PromotedEmail::Signup', inverse_of: :user, dependent: :destroy

  has_many :spam_filter_values, class_name: 'Spam::FilterValue', foreign_key: :added_by_id, inverse_of: :added_by, dependent: :nullify
  has_many :spam_rulesets, class_name: 'Spam::Ruleset', foreign_key: :added_by_id, inverse_of: :added_by, dependent: :nullify
  has_many :spam_action_logs, class_name: 'Spam::ActionLog', foreign_key: :user_id, inverse_of: :user, dependent: :destroy
  has_many :spam_reports, class_name: 'Spam::Report', foreign_key: :user_id, inverse_of: :user, dependent: :destroy
  has_many :handled_spam_reports, class_name: 'Spam::Report', foreign_key: :handled_by_id, inverse_of: :handled_by, dependent: :nullify
  has_many :reverted_spam_actions, class_name: 'Spam::ActionLog', foreign_key: :reverted_by_id, inverse_of: :reverted_by, dependent: :nullify
  has_many :handled_spam_manual_logs, class_name: 'Spam::ManualLog', foreign_key: :handled_by_id, inverse_of: :handled_by, dependent: :destroy
  has_many :reverted_spam_manual_logs, class_name: 'Spam::ManualLog', foreign_key: :reverted_by_id, inverse_of: :reverted_by, dependent: :nullify
  has_many :spam_manual_logs, class_name: 'Spam::ManualLog', foreign_key: :user_id, inverse_of: :user, dependent: :destroy
  has_many :deleted_karma_logs, -> { deprecated },
           class_name: 'Users::DeletedKarmaLog',
           dependent: :destroy,
           inverse_of: :user
  has_one :browser_logs, inverse_of: :user, dependent: :destroy, class_name: 'Users::BrowserLog'
  has_many :story_mentions_associations, class_name: '::Anthologies::StoryMentionsAssociation', as: :subject, inverse_of: :subject, dependent: :destroy
  has_many :scheduled_drip_mails, class_name: 'DripMails::ScheduledMail', inverse_of: :user, dependent: :delete_all

  has_many :post_drafts, class_name: 'PostDraft', inverse_of: :user, dependent: :destroy
  has_many :ab_test_participants, class_name: 'AbTest::Participant', inverse_of: :user, dependent: :destroy

  has_many :badges, class_name: 'Badges::UserAwardBadge', as: :subject, dependent: :destroy
  has_one :crypto_wallet, inverse_of: :user, dependent: :destroy, class_name: 'Users::CryptoWallet'
  has_one :twitter_follower_count, class_name: 'TwitterFollowerCount', as: :subject, dependent: :destroy

  has_many :banners, inverse_of: :user, dependent: :destroy
  has_many :highlighted_changes, inverse_of: :user, dependent: :destroy

  has_many :links, class_name: 'Users::Link', inverse_of: :user, dependent: :destroy
  has_many :activity_events, class_name: 'Users::ActivityEvent', inverse_of: :user, dependent: :destroy
  has_many :upcoming_events, class_name: 'Upcoming::Event', inverse_of: :user, dependent: :destroy
  has_many :user_visit_streak_reminders, class_name: 'UserVisitStreaks::Reminder', inverse_of: :user, dependent: :destroy

  has_many :stacks, class_name: 'Products::Stack', inverse_of: :user, dependent: :destroy
  has_many :alternative_suggestions, class_name: 'Products::AlternativeSuggestion', inverse_of: :user, dependent: :nullify

  store_attributes :notification_preferences do
    subscribed_to_push Boolean, default: false
    send_highlights_browser_push Boolean, default: true
    send_mention_email Boolean, default: true
    send_mention_browser_push Boolean, default: true
    send_friend_post_email Boolean, default: true
    send_friend_post_browser_push Boolean, default: true
    send_new_follower_email Boolean, default: true
    send_new_follower_browser_push Boolean, default: true
    send_announcement_browser_push Boolean, default: true
    send_product_request_email Boolean, lazy: true, default: :send_mention_email
    send_product_request_browser_push Boolean, lazy: true, default: :send_mention_browser_push
    send_product_updates_email Boolean, default: true
    send_collection_digest_email Boolean, default: true
    send_email_digest_email Boolean, default: true
    send_upcoming_page_stats_email Boolean, default: true
    send_stripe_discount_email Boolean, default: true
    send_upcoming_page_promotion_scheduled_email Boolean, default: true
    send_shoutout_mention_email Boolean, default: true
    send_vote_browser_push Boolean, default: true
    send_maker_group_member_browser_push Boolean, default: true
    send_maker_report_email Boolean, default: true
    send_maker_instructions_email Boolean, default: true
    send_dead_link_report_email Boolean, default: true
    send_featured_maker_email Boolean, default: true
    send_comment_digest_email Boolean, default: true
    send_discussion_created_email Boolean, default: true
    send_onboarding_email Boolean, default: true
    send_onboarding_post_launch_email Boolean, default: true
    send_golden_kitty_email Boolean, default: true
    send_makers_festival_email Boolean, default: true
    send_user_badge_award_email Boolean, default: true
    send_ph_recommendations_email Boolean, default: true
    received_makers_fest_email_snapchat Boolean, default: false
    received_makers_fest_email_wfh Boolean, default: false
    send_awarded_badges_email Boolean, default: true
    send_promotions_email Boolean, lazy: true, default: :send_onboarding_post_launch_email

    # Note (Mike Coutermarsh): These are not used
    send_product_recommendation_email Boolean, default: true
    send_product_recommendation_browser_push Boolean, default: true
    send_upvoted_by_friends_email Boolean, default: true
  end

  store_attributes :job_preference do
    remote Boolean, default: false
  end

  before_validation :downcase_username
  before_validation :set_defaults

  validates :name, length: { maximum: MAX_LENGTH_NAME }, presence: true
  validates :username, presence: true, uniqueness: { conditions: -> { visible } }
  validates :headline, length: { maximum: MAX_LENGTH_HEADLINE }, allow_blank: true, on: :update
  validates :website_url, url: { allow_blank: true }
  validates :about, length: { maximum: MAX_LENGTH_ABOUT }, allow_blank: true

  SignIn::VALIDATION_ATTRIBUTES.each do |attribute_name|
    validates attribute_name, presence: true, unless: :any_social_uids?
  end

  # NOTE(vesln): If you add a role here, also add it in app/services/users/better_role.rb
  ROLES = { user: 0, can_post: 2, spammer: 3, potential_spammer: 10, bad_actor: 12, company: 20, external_moderator: 50, admin: 100 }.freeze
  enum role: ROLES

  enum role_reason: {
    self_promotion_comments: 1,
    mass_messaging_chat: 2,
    inappropriate_comments: 3,
    inappropriate_posts: 4,
  }

  enum default_goal_session_duration: {
    '25m': 25,
    '1h': 60,
    '3h': 180,
    # This will mark goals as current until midnight
    allday: 1440,
  }

  explicit_counter_cache :completed_goals_count, -> { goals.completed }
  explicit_counter_cache :helpful_recommendations_count, -> { recommendations.helpful }
  explicit_counter_cache :maker_group_memberships_count, -> { maker_group_memberships }
  explicit_counter_cache :user_follow_product_request_associations_count, -> { user_follow_product_request_associations }
  explicit_counter_cache :notification_feed_items_unread_count, -> { feed_items.visible.where(Stream::FeedItem.arel_table[:last_occurrence_at].gt(notification_feed_last_seen_at)) }
  explicit_counter_cache :votes_count, -> { voted_posts.visible }
  explicit_counter_cache :subscribed_collections_count, -> { subscribed_collections }
  explicit_counter_cache :upcoming_pages_count, -> { UpcomingPage.not_trashed.for_maintainers(self) }
  explicit_counter_cache :subscribed_upcoming_pages_count, -> { subscribed_upcoming_pages }
  explicit_counter_cache :badges_count, -> { badges.complete }
  explicit_counter_cache :badges_unique_count, -> { badges.complete.group("data->'identifier'").count.map { |k, _| k } }

  scope :searchable, -> { not_trashed }
  scope :visible, -> { not_trashed }
  scope :with_preloads, -> { preload preload_attributes }
  scope :non_admin, -> { where.not(role: roles[:admin]) }
  scope :non_spammer, -> { where.not(role: roles.slice(*Spam::User::SPAMMER_ROLES).values) }
  scope :credible, -> { where.not(role: roles.slice(*Spam::User::NON_CREDIBLE_ROLES).values) }
  scope :by_follower_count, -> { order(follower_count: :desc) }
  scope :public_profile, -> { where(private_profile: false) }
  scope :sitemap, -> { visible.non_spammer.public_profile.where(arel_table[:follower_count].gt(150).or(arel_table[:twitter_verified].eq(true))) }
  scope :with_notification_preferences, ->(key, value = true) { where('notification_preferences @> ?', { key => value }.to_json) }
  scope :with_makers_fest_email_received, ->(festival) { with_notification_preferences("received_makers_fest_email_#{ festival.slug }") }
  scope :without_makers_fest_email_received, ->(festival) { with_notification_preferences("received_makers_fest_email_#{ festival.slug }", false) }
  scope :above_credible_karma_min, -> { where('karma_points > ?', Karma.min_credible_karama) }
  scope :ambassador, -> { where(ambassador: true) }

  delegate :email, to: :subscriber, allow_nil: true
  delegate :email_confirmed?, to: :subscriber, allow_nil: true

  ransacker :commented do |_|
    Arel.sql('( users.comments_count > 0 )')
  end
  ransacker :posted_or_made do |_|
    Arel.sql('( users.posts_count > 0 or users.product_makers_count > 0)')
  end

  class << self
    def preload_attributes
      %i(invited_by product_makers)
    end

    def by_usernames(usernames)
      usernames = Array(usernames).compact.map(&:downcase)
      usernames.present? ? visible.where(username: usernames) : none
    end

    def find_by_username(username)
      visible.find_by(username: username.downcase)
    end

    def find_by_username!(username)
      visible.find_by!(username: username.downcase)
    end

    def order_by_friends(user_or_id)
      UserFriendAssociation.apply_order_by_friends(self, 'users.id', user_or_id)
    end

    def find_by_email(email)
      return if email.blank?

      visible.joins(:subscriber).find_by 'notifications_subscribers.email' => email
    end

    def find_query(query)
      visible.where('name ILIKE :like OR username ILIKE :like', like: LikeMatch.start_with(query))
    end
  end

  def flipper_id
    id
  end

  def follows?(user)
    return false unless user

    user_friend_associations.where(following_user_id: user.id).exists?
  end

  def maker?
    product_makers.of_visible_posts.exists?
  end

  def ship_pro?
    Ships::Subscription.new(self).premium?
  end

  def first_time_user?
    login_count == 1
  end

  def verified?
    !!subscriber&.email_confirmed?
  end

  def connected_social_accounts_count
    SignIn::VALIDATION_ATTRIBUTES.map { |attribute_name| self[attribute_name].present? }.count(true)
  end

  def twitter_write_permission?
    access_tokens.twitter.write_access.exists?
  end

  def facebook_write_permission?
    access_tokens.facebook.write_access.exists?
  end

  def first_name
    name && name.strip.split(/\s+/).first
  end

  def last_name
    name && name.strip.split(/\s+/)[1..-1]&.join(' ')
  end

  def friendly_name
    first_name || (username && "@#{ username }")
  end

  def recent_maker_discussion
    discussion_threads.where(subject_type: 'MakerGroup').visible.order(created_at: :desc).limit(1).first
  end

  def received_makers_fest_email?(festival)
    notification_preferences["received_makers_fest_email_#{ festival.slug }"]
  end

  def received_makers_fest_email_for=(festival)
    notification_preferences["received_makers_fest_email_#{ festival.slug }"] = true
  end

  def blocked?
    spammer? || potential_spammer? || bad_actor?
  end

  def verified_legit_user?
    !blocked? && verified?
  end

  def can_receive_email?
    verified_legit_user? && email.present?
  end

  def reindex_associations?
    saved_change_to_username? || saved_change_to_name?
  end

  def searchable_data
    Search.document(
      self,
      name: [name, username].compact,
      body: [headline, about].compact,
      meta: {
        maker: product_makers_count > 0,
        hunter: posts_count > 0,
        url: links.map(&:url),
      },
    )
  end

  REINDEX_KEYS = %w(name username headline votes_count product_makers_count trashed_at).freeze
  def should_reindex_search?
    (REINDEX_KEYS - saved_changes.keys).size < REINDEX_KEYS.size
  end

  def hunted_or_made
    Post.not_trashed.union(made.to_sql).union(hunted.to_sql).distinct
  end

  def hunted
    posts
  end

  def made
    base = Post.left_outer_joins(:product_makers)
    base.where(product_makers: { user_id: id })
  end

  # NOTE(rstankov): This is a workaround the following Psych (shipped in ruby 2.7.5) bug
  #
  #    Psych.dump a: '1_'            #=> raises invalid value for Integer(): "1_"
  #
  #   Which causes the following to fail
  #     create :user, username: '1_' #=> raises invalid value for Integer(): "1_"
  #
  #   Why are we affected by this?
  #     Audited, stores `audited_changes` in YAML format and uses Psych to store those.
  #
  #   We can remove this workaround in the future if one of the following happens:
  #    * We move Audited to use jsonb instead of YAML for audited_changes
  #    * Migrate to Ruby 3 and Psych had fixed this issue
  #
  #   There is a spec covering this.
  def write_audit(attrs)
    attrs[:audited_changes]['audited_username'] = "@#{ attrs[:audited_changes].delete('username') }" if attrs[:audited_changes]['username'].present?

    super(attrs)
  end

  def reset_all_counters
    reset_explicit_counters

    counters = %i(user_flags comments posts product_makers mobile_devices goals)
    self.class.reset_counters(id, *counters, touch: true)

    reload
    true
  end

  private

  def before_trashing
    self.username = "deleted-#{ id }"
    self.twitter_username = nil
    self.twitter_access_token = nil
    self.twitter_access_secret = nil

    SpamChecks.sandbox_trashed_user_votes self

    SignIn::SOCIAL_ATTRIBUTES.each do |attribute_name|
      self[attribute_name] = nil
    end

    if subscriber.present?
      subscriber.clear_tokens
      subscriber.newsletter_subscription = Newsletter::Subscriptions::UNSUBSCRIBED
      subscriber.jobs_newsletter_subscription = Jobs::Newsletter::Subscriptions::UNSUBSCRIBED
      subscriber.save!
    end

    Ships::CancelSubscription.call(user: self, at_period_end: false) if ship_subscription.present?

    ship_contacts.update_all user_id: nil

    Notifications::UserPreferences.unsubscribe_from_all(self)

    UserFriendAssociation.where(followed_by_user_id: id)
                         .or(UserFriendAssociation.where(following_user_id: id)).destroy_all
  end

  def any_social_uids?
    connected_social_accounts_count > 0 || trashed?
  end

  def set_defaults
    self.role ||= :user
    self.karma_points ||= 0
  end

  def downcase_username
    username.downcase! if username.present?
  end
end
