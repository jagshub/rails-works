# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_links
#
#  id               :integer          not null, primary key
#  upcoming_page_id :integer          not null
#  url              :string           not null
#  kind             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_upcoming_page_links_on_kind              (kind)
#  index_upcoming_page_links_on_upcoming_page_id  (upcoming_page_id)
#

class UpcomingPageLink < ApplicationRecord
  belongs_to :upcoming_page, inverse_of: :links

  validates :url, presence: true, url: true
  validates :kind, presence: true

  validate :ensure_valid_kind
  validate :ensure_url_matches_kind

  private

  def ensure_valid_kind
    errors.add :kind, :invalid unless LinkKind.valid_kind?(kind)
  end

  def ensure_url_matches_kind
    errors.add :url, :invalid unless LinkKind.match_kind?(url, kind: kind)
  end
end
