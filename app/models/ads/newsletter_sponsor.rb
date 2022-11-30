# frozen_string_literal: true

# == Schema Information
#
# Table name: ads_newsletter_sponsors
#
#  id               :bigint(8)        not null, primary key
#  budget_id        :bigint(8)
#  image_uuid       :string           not null
#  url              :string           not null
#  url_params       :json             not null
#  description_html :string           not null
#  cta              :string
#  active           :boolean          default(TRUE), not null
#  weight           :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  opens_count      :integer          default(0), not null
#  clicks_count     :integer          default(0), not null
#  sents_count      :integer          default(0), not null
#  body_image_uuid  :string
#
# Indexes
#
#  index_ads_newsletter_sponsors_on_active_and_weight  (active,weight)
#  index_ads_newsletter_sponsors_on_budget_id          (budget_id)
#
# Foreign Keys
#
#  fk_rails_...  (budget_id => ads_budgets.id)
#
class Ads::NewsletterSponsor < ApplicationRecord
  include HasUrlParams
  include Namespaceable
  include Uploadable

  uploadable :image
  uploadable :body_image

  audited associated_with: :budget, only: %i(
    active
    body_image_uuid
    cta
    description_html
    image_uuid
    url
    url_params
    weight
  )

  belongs_to :budget, class_name: 'Ads::Budget', inverse_of: :newsletter_sponsor

  has_many :interactions,
           class_name: 'Ads::NewsletterInteraction',
           as: :subject,
           dependent: :destroy

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_weight, -> { order(weight: :desc) }

  validates :image_uuid, presence: true
  validates :url, presence: true
  validates :description_html, presence: true

  before_save :clean_description_html_and_url

  # NOTE(DZ): Activate active admin create form
  attribute :_create

  # NOTE(DZ): Translation methods for newsletter sponsor template
  # app/views/notification_mailer/_newsletter_sponsor.html.erb
  def link
    Routes.ads_newsletter_sponsor_redirect_url(self)
  end

  def can_be_destroyed?
    persisted? && interactions.empty?
  end

  private

  def clean_description_html_and_url
    self.description_html = HtmlSanitize.call(description_html)
    self.url = url&.strip
  end
end
