# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_surveys
#
#  id                    :integer          not null, primary key
#  title                 :string           not null
#  upcoming_page_id      :integer          not null
#  status                :integer          default("draft"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  trashed_at            :datetime
#  background_image_uuid :string
#  background_color      :string
#  button_color          :string
#  title_color           :string
#  link_color            :string
#  button_text_color     :string
#  closed_at             :datetime
#  description_html      :text
#  success_html          :text
#  welcome_html          :text
#
# Indexes
#
#  index_upcoming_page_surveys_on_upcoming_page_id  (upcoming_page_id)
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_id => upcoming_pages.id)
#

class UpcomingPageSurvey < ApplicationRecord
  include Trashable
  include SlateFieldOverride

  slate_field :description, mode: :everything
  slate_field :success_text, html_field: :success_html, mode: :everything
  slate_field :welcome_text, html_field: :welcome_html, mode: :everything

  HasTimeAsFlag.define self, :closed

  belongs_to :upcoming_page, inverse_of: :surveys

  has_many :questions, -> { not_trashed }, class_name: 'UpcomingPageQuestion', dependent: :destroy, inverse_of: :survey
  has_many :answers, through: :questions, source: :answers
  has_many :subscribers, -> { distinct }, through: :answers, source: :subscriber

  delegate :account, to: :upcoming_page

  validates :title, presence: true, uniqueness: { scope: :upcoming_page_id }
  validates :button_color, css_hex_color: true, allow_blank: true
  validates :button_text_color, css_hex_color: true, allow_blank: true
  validates :link_color, css_hex_color: true, allow_blank: true
  validates :background_color, css_hex_color: true, allow_blank: true
  validates :title_color, css_hex_color: true, allow_blank: true

  scope :by_created_at, -> { order('created_at DESC') }
  scope :visible, -> { where.not(status: statuses[:draft]) }
  scope :opened, -> { not_closed.where.not(status: statuses[:draft]) }

  enum status: {
    draft: 0,
    active: 1,
    used_in_upcoming_page: 2,
  }

  attr_readonly :upcoming_page_id

  def opened?
    return false if draft?
    return false if closed?
    return false unless Ships::Subscription.from_account(account).can_use_surveys?

    true
  end
end
