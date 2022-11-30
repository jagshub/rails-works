# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_messages
#
#  id                      :integer          not null, primary key
#  subject                 :string           not null
#  comments_count          :integer          default(0), not null
#  upcoming_page_id        :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  state                   :integer          default("draft"), not null
#  slug                    :string
#  sent_to_count           :integer          default(0), not null
#  subscriber_filters      :jsonb            not null
#  user_id                 :integer
#  layout                  :integer          default("status_update"), not null
#  upcoming_page_survey_id :integer
#  post_id                 :integer
#  visibility              :integer          default("public"), not null
#  kind                    :integer          default("one_off"), not null
#  body_html               :text
#  sent_count              :integer          default(0)
#  opened_count            :integer          default(0)
#  clicked_count           :integer          default(0)
#  failed_count            :integer          default(0)
#
# Indexes
#
#  index_upcoming_page_messages_on_post_id                  (post_id)
#  index_upcoming_page_messages_on_slug                     (slug)
#  index_upcoming_page_messages_on_upcoming_page_survey_id  (upcoming_page_survey_id)
#  index_upcoming_page_messages_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (upcoming_page_survey_id => upcoming_page_surveys.id)
#  fk_rails_...  (user_id => users.id)
#

class UpcomingPageMessage < ApplicationRecord
  include Sluggable
  include Commentable

  # Note(andreasklinger): see monkey_patches/jsonb_monkey_patch.rb
  include JsonbTypeMonkeyPatch[:subscriber_filters]
  include SlateFieldOverride

  explicit_counter_cache :sent_count, -> { deliveries.sent }
  explicit_counter_cache :opened_count, -> { deliveries.opened }
  explicit_counter_cache :clicked_count, -> { deliveries.clicked }
  explicit_counter_cache :failed_count, -> { deliveries.failed }

  slate_field :body, html_field: :body_html, mode: :everything

  sluggable

  belongs_to :upcoming_page
  belongs_to :user, optional: true
  belongs_to :upcoming_page_segment, optional: true
  belongs_to :upcoming_page_question_option, optional: true
  belongs_to :survey, class_name: 'UpcomingPageSurvey', foreign_key: :upcoming_page_survey_id, optional: true
  belongs_to :post, optional: true

  has_one :product, required: false, through: :post

  has_many :deliveries,
           class_name: 'UpcomingPageMessageDelivery',
           dependent: :delete_all,
           inverse_of: :subject,
           as: :subject

  has_many :conversations, class_name: 'UpcomingPageConversation', dependent: :destroy

  validates :subject, presence: true
  validates :upcoming_page_survey_id, presence: true, if: :layout_survey?
  validates :post_id, presence: true, if: :layout_launch?

  validate :user_is_upcoming_page_maker, on: :create

  enum state: {
    draft: 0,
    sent: 100,
    paused: 200,
  }

  enum kind: {
    one_off: 0,
    continuous: 100,
  }

  enum layout: {
    status_update: 0,
    survey: 100,
    launch: 200,
    personal: 300,
  }, _prefix: :layout

  enum visibility: {
    public: 0,
    private: 100,
  }, _prefix: :visibility

  scope :by_created_at, -> { order(arel_table[:created_at].desc) }

  scope :this_week, -> { where(arel_table[:created_at].gt(Time.zone.now.beginning_of_week)) }
  scope :today, -> { where(arel_table[:created_at].gt(Time.zone.now.beginning_of_day)) }

  scope :publicly_accessible, -> { visibility_public.where.not(state: 0) }

  def publicly_accessible?
    visibility_public? && !draft?
  end

  def to
    UpcomingPages::SubscriberSearch.results(upcoming_page, subscriber_filters)
  end

  def author
    user || upcoming_page.user
  end

  def mailjet_campaign
    "upcoming_page_message_#{ upcoming_page_id }_#{ id }"
  end

  private

  def sluggable_candidates
    [:subject, %i(subject sluggable_sequence)]
  end

  def sluggable_sequence
    slug = normalize_friendly_id(subject)
    counter = slug_scope.where("slug ~* '^#{ slug }(-[0-9]+)?$'").count
    counter + 1
  end

  def should_generate_new_friendly_id?
    slug.blank? || subject_changed?
  end

  def user_is_upcoming_page_maker
    return if user.blank? || upcoming_page.blank?
    return if user == upcoming_page.user
    return if user == upcoming_page.account.user
    return if upcoming_page.account.members.exists?(user_id)

    errors.add(:user_id, 'is not a maker')
  end
end
