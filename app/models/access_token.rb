# frozen_string_literal: true

# == Schema Information
#
# Table name: access_tokens
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  token_type        :integer          not null
#  created_at        :datetime         not null
#  expires_at        :datetime
#  unavailable_until :datetime
#  permissions       :integer          default("read_only_access"), not null
#  token             :text
#  secret            :text
#
# Indexes
#
#  index_access_tokens_on_token_type_and_unavailable_until  (token_type,unavailable_until NULLS FIRST)
#  index_access_tokens_on_unavailable_until                 (unavailable_until)
#  index_access_tokens_on_user_id_and_token_type            (user_id,token_type) UNIQUE
#

class AccessToken < ApplicationRecord
  # Note(LukasFittl): This means that a token has been used for Friend Sync and
  #   shouldn't be immediately used again for that purpose. You can use it for
  #   other, less rate limit prone calls though (e.g. share actions).
  scope :available_for_sync, -> { where(arel_table[:unavailable_until].eq(nil).or(arel_table[:unavailable_until].lt(Time.zone.now))) }

  belongs_to :user
  validates :user, uniqueness: { scope: :token_type }

  enum token_type: { twitter: 0, facebook: 1, angellist: 3, google: 4, apple: 5 }

  enum permissions: { read_only_access: 0, write_access: 10 }

  # Note (LukasFittl): Sometimes providers experience intermittent errors on tokens,
  #   discard this one for now and retry using it in a day's time.
  def invalidate_temporarily!
    update! unavailable_until: 24.hours.from_now
  end

  def expired?
    return false if expires_at.blank?

    Time.zone.now.past?
  end
end
