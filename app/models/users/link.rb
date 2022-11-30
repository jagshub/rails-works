# frozen_string_literal: true

# == Schema Information
#
# Table name: users_links
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  url        :string           not null
#  kind       :string           default("website"), not null
#  user_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_links_on_user_id_and_url  (user_id,url) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Users::Link < ApplicationRecord
  include Namespaceable

  belongs_to :user, inverse_of: :links

  validates :name, presence: true, length: { maximum: 100 }
  validates :url, url: true, presence: true, uniqueness: { case_sensitive: false, scope: :user }

  audited on: :destroy

  extension(
    Search.searchable_association,
    association: :user,
    if: :saved_change_to_url?,
  )

  enum kind: {
    angellist: 'angellist',
    app_store: 'app_store',
    behance: 'behance',
    dribbble: 'dribbble',
    facebook: 'facebook',
    github: 'github',
    instagram: 'instagram',
    linkedin: 'linkedin',
    play_store: 'play_store',
    reddit: 'reddit',
    tiktok: 'tiktok',
    twitter: 'twitter',
    vimeo: 'vimeo',
    website: 'website',
    youtube: 'youtube',
  }

  before_validation :set_link_type_from_url
  before_validation :set_url_to_downcase

  class << self
    def find_by_url(url)
      find_by(url: url.downcase)
    end
  end

  private

  def set_url_to_downcase
    self.url = url.downcase
  end

  def set_link_type_from_url
    return if url.blank?

    self.kind = Users::LinkKind.kind_from_url(url)
  end
end
