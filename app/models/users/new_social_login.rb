# frozen_string_literal: true

# == Schema Information
#
# Table name: users_new_social_logins
#
#  id                 :bigint(8)        not null, primary key
#  user_id            :bigint(8)        not null
#  state              :string           default("requested"), not null
#  social             :string           not null
#  email              :string           not null
#  token              :string           not null
#  expires_at         :datetime         not null
#  auth_response      :jsonb            not null
#  via_application_id :integer
#
# Indexes
#
#  index_users_new_social_logins_on_state    (state)
#  index_users_new_social_logins_on_token    (token)
#  index_users_new_social_logins_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Users::NewSocialLogin < ApplicationRecord
  include Namespaceable
  include JsonbTypeMonkeyPatch[:auth_response]

  extension HasUniqueCode, field_name: :token, length: 32
  extension HasExpirationDate, limit: 24.hours

  belongs_to :user, inverse_of: :new_social_login_requests

  enum state: {
    requested: 'requested',
    merged: 'merged',
    separated: 'separated',
    browser_invalid: 'browser_invalid',
  }

  enum social: {
    facebook: 'facebook',
    twitter: 'twitter',
    angellist: 'angellist',
    google: 'google',
    apple: 'apple',
    googleonetap: 'googleonetap',
  }

  validates :email, email_format: true, presence: true
  validates :token, presence: true
  validates :state, presence: true

  scope :processable, -> { not_expired.requested.or(browser_invalid) }

  def processable?
    !expired? && (requested? || browser_invalid?)
  end
end
