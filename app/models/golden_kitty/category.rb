# frozen_string_literal: true

# == Schema Information
#
# Table name: golden_kitty_categories
#
#  id                           :integer          not null, primary key
#  name                         :string           not null
#  tagline                      :string
#  emoji                        :string
#  nomination_question          :string
#  year                         :integer          default("2018"), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  topic_id                     :integer
#  sponsor_id                   :integer
#  priority                     :integer          default(0), not null
#  slug                         :string
#  voting_enabled_at            :datetime
#  social_image_uuid            :string
#  edition_id                   :bigint(8)
#  social_image_nomination_uuid :string
#  social_image_voting_uuid     :string
#  social_image_result_uuid     :string
#  social_image_pre_voting_uuid :string
#  social_image_pre_result_uuid :string
#  icon_uuid                    :string
#  people_category              :boolean          default(FALSE), not null
#
# Indexes
#
#  index_golden_kitty_categories_on_edition_id         (edition_id)
#  index_golden_kitty_categories_on_slug_and_year      (slug,year) UNIQUE
#  index_golden_kitty_categories_on_topic_id           (topic_id)
#  index_golden_kitty_categories_on_voting_enabled_at  (voting_enabled_at)
#
# Foreign Keys
#
#  fk_rails_...  (edition_id => golden_kitty_editions.id)
#  fk_rails_...  (sponsor_id => golden_kitty_sponsors.id)
#  fk_rails_...  (topic_id => topics.id)
#

class GoldenKitty::Category < ApplicationRecord
  include Namespaceable
  include Prioritisable
  include Sluggable
  include Uploadable

  uploadable :icon
  uploadable :social_image
  uploadable :social_image_nomination
  uploadable :social_image_pre_voting
  uploadable :social_image_voting
  uploadable :social_image_pre_result
  uploadable :social_image_result

  sluggable scope: :year

  validates :name, :year, presence: true
  validate :emoji_or_icon

  belongs_to :topic, inverse_of: :golden_kitty_categories, optional: true

  enum year: {
    '2015': 4,
    '2016': 5,
    '2017': 6,
    '2018': 0,
    '2019': 1,
    '2020': 2,
    '2021': 3,
    '2022': 7,
  }

  belongs_to :sponsor, class_name: '::GoldenKitty::Sponsor', inverse_of: :golden_kitty_categories, optional: true
  belongs_to :edition, class_name: '::GoldenKitty::Edition', inverse_of: :categories
  has_many :facts, class_name: '::GoldenKitty::Fact', inverse_of: :category, dependent: :destroy
  has_many :nominees, class_name: '::GoldenKitty::Nominee', inverse_of: :golden_kitty_category, foreign_key: 'golden_kitty_category_id', dependent: :destroy
  has_many :finalists, class_name: '::GoldenKitty::Finalist', inverse_of: :golden_kitty_category, foreign_key: 'golden_kitty_category_id', dependent: :destroy
  has_many :people, class_name: '::GoldenKitty::Person', inverse_of: :golden_kitty_category, foreign_key: 'golden_kitty_category_id', dependent: :destroy

  START_DATE = '2019-01-01'
  END_DATE = '2019-12-31'

  scope :by_voting_enabled, -> { where('voting_enabled_at <= ?', Time.zone.now) }
  scope :with_voting_for_year, ->(year) { where(year: year).by_voting_enabled.order(voting_enabled_at: :asc).by_priority }
  scope :by_year, -> { order('year DESC') }
  scope :with_year, ->(year) { where(year: years[year.to_s]) }
  scope :sponsored, -> { where.not(sponsor: nil) }

  SOCIAL_IMAGE_COLUMNS = %w(
    social_image
    social_image_nomination
    social_image_pre_voting
    social_image_voting
    social_image_pre_result
    social_image_result
  ).freeze

  class << self
    def social_image_columns
      SOCIAL_IMAGE_COLUMNS
    end
  end

  delegate :year, to: :edition, allow_nil: true

  def phase(user = nil)
    GoldenKitty.phase_for_category(self, user)
  end

  def voting_enabled?(user = nil)
    phase(user) == :voting
  end

  def next_voting_category
    voting_categories[index_in_voting_category + 1]
  end

  def previous_voting_category
    index = index_in_voting_category
    index > 0 ? voting_categories[index - 1] : nil
  end

  def to_param
    # NOTE(rstankov): Overwrite, so admin can allow editing categories with same slug
    id
  end

  def winners
    scope = people_category? ? people : finalists

    scope.where(winner: true).order(position: :asc)
  end

  private

  def emoji_or_icon
    return if emoji.present? || icon_uuid.present?

    errors.add(:base, 'emoji or icon is required')
  end

  def voting_categories
    @voting_categories ||= self.class.with_voting_for_year(year)
  end

  def index_in_voting_category
    voting_categories.find_index { |category| category.slug == slug } || 0
  end
end
