# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_subscribers
#
#  id                  :integer          not null, primary key
#  token               :string           not null
#  upcoming_page_id    :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  state               :integer          default("pending"), not null
#  source_kind         :string
#  source_reference_id :string
#  unsubscribe_source  :string
#  ship_contact_id     :integer          not null
#
# Indexes
#
#  index_upcoming_page_subscribers_on_page_id_and_contact_id      (upcoming_page_id,ship_contact_id) UNIQUE
#  index_upcoming_page_subscribers_on_ship_contact_id             (ship_contact_id)
#  index_upcoming_page_subscribers_on_source_kind                 (source_kind)
#  index_upcoming_page_subscribers_on_upcoming_page_id_and_state  (upcoming_page_id,state)
#
# Foreign Keys
#
#  fk_rails_...  (ship_contact_id => ship_contacts.id)
#

class UpcomingPageSubscriber < ApplicationRecord
  HasUniqueCode.define self, field_name: :token, length: 34

  belongs_to :upcoming_page
  belongs_to :contact, class_name: 'ShipContact', foreign_key: 'ship_contact_id', inverse_of: :subscribers

  has_many :upcoming_page_segment_subscriber_associations, dependent: :delete_all, inverse_of: :upcoming_page_subscriber
  has_many :answers, class_name: 'UpcomingPageQuestionAnswer', dependent: :delete_all, inverse_of: :subscriber
  has_many :message_deliveries, class_name: 'UpcomingPageMessageDelivery', dependent: :delete_all, inverse_of: :subscriber
  has_many :conversation_messages, class_name: 'UpcomingPageConversationMessage', dependent: :destroy, inverse_of: :subscriber

  has_many :segments, through: :upcoming_page_segment_subscriber_associations, source: :upcoming_page_segment

  delegate :email, :user, :user_id, :name, :avatar_url, to: :contact

  validates :token, presence: true

  after_commit :refresh_counters

  enum state: { pending: 0, confirmed: 100, unsubscribed: 200 }

  scope :between_dates, ->(start_date, end_date) { where_date_between(:created_at, start_date, end_date) }
  scope :by_user_follower_count, -> { joins(:contact).joins('LEFT JOIN users ON users.id = ship_contacts.user_id').order('users.follower_count DESC NULLS LAST') }
  scope :by_created_at, -> { order('created_at DESC') }
  scope :for_variant, ->(variant) { where source_kind: "variant_#{ variant.kind }", source_reference_id: variant.id, upcoming_page_id: variant.upcoming_page_id }
  scope :created_after, ->(date) { where(arel_table[:created_at].gteq(date)) }
  scope :created_before, ->(date) { where(arel_table[:created_at].lteq(date)) }

  scope :imported, -> { joins(:contact).where('ship_contacts.origin' => 1) }
  scope :not_imported, -> { joins(:contact).where.not('ship_contacts.origin' => 1) }
  scope :user, -> { joins(:contact).where.not('ship_contacts.user_id' => nil) }
  scope :guest, -> { joins(:contact).where('ship_contacts.user_id' => nil) }
  scope :maker, -> { joins(:contact).where('ship_contacts.user_id' => ProductMaker.select(:user_id)) }
  scope :by_segment_id, ->(id) { joins(:upcoming_page_segment_subscriber_associations).where(upcoming_page_segment_subscriber_associations: { upcoming_page_segment_id: id }) }
  scope :for_email, ->(email) { joins(:contact).where('ship_contacts.email ILIKE ?', LikeMatch.by_words(email)) }
  scope :for_user, ->(user_id) { joins(:contact).where('ship_contacts.user_id' => user_id) }

  class << self
    def find_by_email(email)
      joins(:contact).find_by 'ship_contacts.email' => email
    end

    def for_query(query)
      joins(:contact)
        .joins('LEFT JOIN users ON users.id = ship_contacts.user_id')
        .where('users.name ILIKE :match OR users.username LIKE :match OR ship_contacts.email ILIKE :match', match: LikeMatch.by_words(query))
    end

    def not_spammer
      joins(:contact)
        .joins('LEFT JOIN users ON users.id = ship_contacts.user_id')
        .where('ship_contacts.user_id IS NULL OR users.role NOT IN (?)', Spam::User::SPAMMER_ROLES.map { |role| User.roles[role] })
    end
  end

  private

  def refresh_counters
    upcoming_page.refresh_subscriber_count
    user.refresh_subscribed_upcoming_pages_count if user.present?
  end
end
