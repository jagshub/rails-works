# frozen_string_literal: true

# == Schema Information
#
# Table name: link_spect_logs
#
#  id            :bigint(8)        not null, primary key
#  external_link :string           not null
#  blocked       :boolean          default(FALSE), not null
#  source        :integer          default("safe_browsing"), not null
#  expires_at    :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_link_spect_logs_on_external_link_and_expires_at  (external_link,expires_at)
#

class LinkSpect::Log < ApplicationRecord
  include Namespaceable
  validates :external_link, presence: true
  validates :expires_at, presence: true

  before_save :encode_link

  scope :active, ->(now = Time.zone.now) { where('expires_at > ?', now) }

  enum source: {
    safe_browsing: 0,
    awis: 1,
    admin: 2,
  }

  def encode_link
    self.external_link = Addressable::URI.encode(external_link)
  end
end
