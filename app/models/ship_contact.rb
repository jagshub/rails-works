# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_contacts
#
#  id                         :integer          not null, primary key
#  ship_account_id            :integer          not null
#  user_id                    :integer
#  clearbit_person_profile_id :integer
#  email                      :string           not null
#  email_confirmed            :boolean          default(FALSE), not null
#  token                      :string           not null
#  origin                     :integer          default("from_subscription"), not null
#  device_type                :integer
#  os                         :string
#  user_agent                 :string
#  ip_address                 :string
#  unsubscribed_at            :datetime
#  trashed_at                 :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_ship_contacts_on_clearbit_person_profile_id      (clearbit_person_profile_id)
#  index_ship_contacts_on_email_and_email_confirmed       (email,email_confirmed)
#  index_ship_contacts_on_ship_account_id_and_email       (ship_account_id,email) UNIQUE
#  index_ship_contacts_on_ship_account_id_and_trashed_at  (ship_account_id,trashed_at)
#  index_ship_contacts_on_token                           (token) UNIQUE
#  index_ship_contacts_on_user_id                         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (clearbit_person_profile_id => clearbit_person_profiles.id)
#  fk_rails_...  (ship_account_id => ship_accounts.id)
#  fk_rails_...  (user_id => users.id)
#

class ShipContact < ApplicationRecord
  include Trashable

  HasEmailField.define self, uniqueness: { scope: :ship_account_id }
  HasUniqueCode.define self, field_name: :token, length: 34

  belongs_to :user, optional: true, inverse_of: :ship_contacts
  belongs_to :clearbit_person_profile, class_name: 'Clearbit::PersonProfile', optional: true, inverse_of: :ship_contacts
  belongs_to :account, class_name: 'ShipAccount', foreign_key: 'ship_account_id', inverse_of: :contacts

  has_many :subscribers, class_name: 'UpcomingPageSubscriber', foreign_key: 'ship_contact_id', inverse_of: :contact, dependent: :destroy
  has_many :active_subscribers, -> { confirmed }, class_name: 'UpcomingPageSubscriber', foreign_key: 'ship_contact_id', inverse_of: :contact

  has_many :message_deliveries, through: :subscribers
  has_many :upcoming_pages, through: :subscribers
  has_many :answers, through: :subscribers

  after_commit :refresh_counters

  validates :token, presence: true

  enum origin: { from_subscription: 0, from_import: 1, from_message_reply: 2 }

  enum device_type: { other: 0, desktop: 100, mobile: 200, tablet: 300 }

  after_commit :refresh_counters

  attr_readonly :origin, :account_id

  scope :with_confirmed_email, -> { where(email_confirmed: true) }

  def name
    user&.name || email
  end

  def avatar_url
    if user
      Users::Avatar.url_for_user(user)
    else
      S3Helper.image_url('guest-user-avatar.png')
    end
  end

  def before_trashing
    subscribers.update_all state: :unsubscribed, unsubscribe_source: 'trash'
  end

  private

  def refresh_counters
    account.refresh_contacts_count
    account.refresh_contacts_from_import_count
    account.refresh_contacts_from_message_reply_count
    account.refresh_contacts_from_subscription_count
  end
end
