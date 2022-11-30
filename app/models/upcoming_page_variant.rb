# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_variants
#
#  id                      :integer          not null, primary key
#  upcoming_page_id        :integer          not null
#  kind                    :integer          not null
#  logo_uuid               :string
#  brand_color             :string
#  background_image_uuid   :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  unsplash_background_url :string
#  thumbnail_uuid          :string
#  template_name           :string           default("default"), not null
#  background_color        :string
#  media                   :jsonb
#  why_html                :text
#  what_html               :text
#  who_html                :text
#
# Indexes
#
#  index_upcoming_page_variants_on_upcoming_page_id_and_kind  (upcoming_page_id,kind) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_id => upcoming_pages.id)
#

class UpcomingPageVariant < ApplicationRecord
  include SlateFieldOverride

  slate_field :who_text, html_field: :who_html, mode: :everything
  slate_field :what_text, html_field: :what_html, mode: :everything
  slate_field :why_text, html_field: :why_html, mode: :everything

  belongs_to :upcoming_page, inverse_of: :variants, touch: true

  TEMPLATE_NAMES = [
    'default',
    'cinematic',
    'split',
  ].freeze

  validates :brand_color, css_hex_color: true, allow_blank: true
  validates :background_color, css_hex_color: true, allow_blank: true
  validates :kind, uniqueness: { scope: :upcoming_page_id }
  validates :template_name, presence: true, inclusion: { in: TEMPLATE_NAMES }

  enum kind: {
    a: 1,
    b: 2,
  }

  scope :by_kind, ->(kind) { where kind: kinds[kind] }
  scope :order_by_kind, -> { order kind: :asc }

  attr_readonly :upcoming_page_id

  delegate :user, to: :upcoming_page

  def subscribers
    @subscribers ||= UpcomingPageSubscriber.created_after(upcoming_page.ab_started_at).for_variant(self)
  end
end
