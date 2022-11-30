# frozen_string_literal: true

# == Schema Information
#
# Table name: newsletters
#
#  id                   :integer          not null, primary key
#  subject              :string           not null
#  status               :integer          default("draft"), not null
#  kind                 :integer          default("daily"), not null
#  date                 :date             not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  sections             :jsonb            not null
#  posts                :jsonb            not null
#  preview_token        :string
#  sips                 :integer          default([]), is an Array
#  meetup_event         :jsonb
#  anthologies_story_id :bigint(8)
#  social_image_uuid    :string
#  skip_sponsor         :boolean          default(FALSE)
#  sponsor_title        :string           default("Sponsored By")
#
# Indexes
#
#  index_newsletters_on_anthologies_story_id  (anthologies_story_id)
#

class Newsletter < ApplicationRecord
  # Note(andreasklinger): see monkey_patches/jsonb_monkey_patch.rb
  include JsonbTypeMonkeyPatch[:sections, :posts]
  include Uploadable

  audited only: %i(status kind date preview_token social_image_uuid title skip_sponsor)

  extension HasStrippableFields, attributes: %i(subject)

  uploadable :social_image

  has_one :promoted_product
  has_many :events, class_name: 'NewsletterEvent', inverse_of: :newsletter, dependent: :destroy
  has_one :experiment, class_name: 'NewsletterExperiment', inverse_of: :newsletter, dependent: :destroy
  belongs_to :anthologies_story, class_name: 'Anthologies::Story', inverse_of: :newsletter, optional: true

  # TODO(DZ): Properly mark this as deprecated
  has_one :sponsor,
          class_name: 'Newsletter::Sponsor',
          inverse_of: :newsletter,
          dependent: :destroy
  # TODO(DZ): Properly mark this as deprecated
  has_one :ad,
          class_name: 'Ads::Newsletter',
          inverse_of: :newsletter,
          dependent: :nullify

  validates :subject, presence: true
  validates :date, presence: true

  enum status: { draft: 0, sent: 1 }
  enum kind: { daily: 0, weekly: 1 }

  attribute :sections, Newsletter::SectionType.new

  scope :by_date, -> { order(arel_table[:created_at].desc) }
  scope :by_sent_date, -> { order('date desc') }

  accepts_nested_attributes_for :sponsor, allow_destroy: true, reject_if: :all_blank

  FROM_EMAIL_ADDRESS = 'hello@digest.producthunt.com'

  def eligible_posts
    @eligible_posts ||= fetch_eligible_posts.to_a
  end

  def posts=(posts)
    posts = posts.to_h.values unless posts.is_a? Array
    super posts
  end

  def sendable?
    draft? && posts.any? && sections.any?(&:present?)
  end

  def date_range
    return [date - 6.days, date] if weekly?
    return [date - 2.days, date] if weekend_newsletter?
    return [date] if daily?

    :invalid_kind
  end

  def weekend_newsletter?
    date.sunday?
  end

  def primary_section
    @primary_section ||= sections.min
  end

  def image_uuid
    @image_uuid ||= sections.sort.find { |s| s.image_uuid.present? }&.image_uuid
  end

  def from_address
    "#{ from_name } <#{ FROM_EMAIL_ADDRESS }>"
  end

  def from_name
    "Product Hunt #{ kind.capitalize }"
  end

  def reply_to_address
    CommunityContact::REPLY
  end

  def subscription_kind
    daily? ? Newsletter::Subscriptions::DAILY : Newsletter::Subscriptions::WEEKLY
  end

  def set_preview_token
    return preview_token if preview_token.present?

    self.preview_token = SecureRandom.hex(2)
  end

  # Note(Rahul): Max url length can be 2,083 but to be safe and clean let's limit to 240
  MAX_SLUG_LENGTH = 240

  def slug
    return id if subject.blank?

    "#{ id }-#{ subject.parameterize }".truncate(MAX_SLUG_LENGTH, separator: '-', omission: '')
  end

  private

  def fetch_eligible_posts
    range = date_range

    if range.count == 1
      Post.for_featured_date(range.first).order('daily_rank ASC').limit(10)
    else
      Post.by_credible_votes.where_date_between(:featured_at, range.first, range.second)
    end
  end
end
