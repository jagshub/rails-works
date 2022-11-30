# frozen_string_literal: true

# == Schema Information
#
# Table name: newsletter_sponsors
#
#  id               :bigint(8)        not null, primary key
#  newsletter_id    :bigint(8)        not null
#  image_uuid       :string           not null
#  link             :string           not null
#  description_html :text             not null
#  body_image_uuid  :string
#  cta              :string
#
# Indexes
#
#  index_newsletter_sponsors_on_newsletter_id  (newsletter_id)
#
# Foreign Keys
#
#  fk_rails_...  (newsletter_id => newsletters.id)
#

class Newsletter::Sponsor < ApplicationRecord
  include Namespaceable

  # NOTE(DZ): Newsletter::Sponsor is deprecated. Use `Ads::NewsletterSponsor`
  # instead. This should be enabled when the full feature is released
  # def readonly?
  #   true
  # end

  belongs_to :newsletter, optional: false

  attr_readonly :newsletter_id

  validates :image_uuid, presence: true
  validates :link, presence: true
  validates :description_html, presence: true
  validate :ensure_link_contains_http_or_https

  before_save do
    self.description_html = HtmlSanitize.call(description_html)
    self.link = link&.strip
  end

  def ensure_link_contains_http_or_https
    return true if link =~ %r{\Ahttps?://.+\z}

    errors.add(:link, 'not valid. Sponsor Link should contain http/https.')
  end
end
