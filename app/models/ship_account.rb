# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_accounts
#
#  id                                :integer          not null, primary key
#  user_id                           :integer          not null
#  ship_subscription_id              :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  contacts_count                    :integer          default(0), not null
#  contacts_from_subscription_count  :integer          default(0), not null
#  contacts_from_message_reply_count :integer          default(0), not null
#  contacts_from_import_count        :integer          default(0), not null
#  name                              :string
#  data_processor_agreement          :integer          default("pending_dpa"), not null
#
# Indexes
#
#  index_ship_accounts_on_ship_subscription_id  (ship_subscription_id) UNIQUE
#  index_ship_accounts_on_user_id               (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (ship_subscription_id => ship_subscriptions.id)
#  fk_rails_...  (user_id => users.id)
#

class ShipAccount < ApplicationRecord
  include ExplicitCounterCache

  belongs_to :user, inverse_of: :ship_account
  belongs_to :subscription, class_name: 'ShipSubscription', foreign_key: 'ship_subscription_id', inverse_of: :account, optional: true

  has_many :contacts_with_trashed, class_name: 'ShipContact', inverse_of: :account
  has_many :ship_account_member_associations, dependent: :delete_all, inverse_of: :account
  has_many :members, through: :ship_account_member_associations, source: :user

  has_one :aws_application, class_name: 'ShipAwsApplication', inverse_of: :ship_account, dependent: :destroy
  has_one :stripe_application, class_name: 'ShipStripeApplication', inverse_of: :account, dependent: :destroy

  CONTENT_ASSOCIATIONS = %i(upcoming_pages contacts).freeze

  # NOTE(rstankov): When adding more content associations update `CONTENT_ASSOCIATIONS`
  has_many :upcoming_pages, inverse_of: :account, dependent: :destroy
  has_many :contacts, -> { not_trashed }, class_name: 'ShipContact', inverse_of: :account, dependent: :destroy

  explicit_counter_cache :contacts_count, -> { contacts }
  explicit_counter_cache :contacts_from_subscription_count, -> { contacts.from_subscription }
  explicit_counter_cache :contacts_from_message_reply_count, -> { contacts.from_message_reply }
  explicit_counter_cache :contacts_from_import_count, -> { contacts.from_import }

  enum data_processor_agreement: {
    pending_dpa: 0,
    declined_dpa: 100,
    accepted_dpa: 200,
  }

  delegate :free?, :monthly?, :trial?, to: :subscription_will_fallback

  def maintainers
    [user] + members
  end

  def content?
    CONTENT_ASSOCIATIONS.any? do |association_name|
      public_send(association_name).any?
    end
  end

  private

  def subscription_will_fallback
    @subcription_with_fallback ||= subscription || ShipSubscription.new(billing_plan: :free, billing_period: :monthly)
  end
end
