# frozen_string_literal: true

# == Schema Information
#
# Table name: golden_kitty_editions
#
#  id                             :bigint(8)        not null, primary key
#  year                           :integer          not null
#  social_share_text              :string
#  nomination_starts_at           :datetime         not null
#  nomination_ends_at             :datetime         not null
#  voting_starts_at               :datetime         not null
#  voting_ends_at                 :datetime         not null
#  result_at                      :datetime         not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  social_text_nomination_started :string
#  social_text_nomination_ended   :string
#  social_text_voting_started     :string
#  social_text_voting_ended       :string
#  social_text_result_announced   :string
#  subscribers_count              :integer          default(0), not null
#  followers_count                :integer          default(0), not null
#  social_image_uuid              :string
#  social_image_nomination_uuid   :string
#  social_image_voting_uuid       :string
#  social_image_result_uuid       :string
#  social_image_pre_voting_uuid   :string
#  social_image_pre_result_uuid   :string
#  results_url                    :string
#  results_description            :string
#  live_event_at                  :datetime
#  card_image_uuid                :string
#

class GoldenKitty::Edition < ApplicationRecord
  include Namespaceable
  include Subscribeable
  include ExplicitCounterCache
  include Uploadable

  uploadable :card_image
  uploadable :social_image
  uploadable :social_image_nomination
  uploadable :social_image_pre_voting
  uploadable :social_image_voting
  uploadable :social_image_pre_result
  uploadable :social_image_result

  has_many :sponsor_associations, class_name: '::GoldenKitty::EditionSponsor', inverse_of: :edition, dependent: :destroy
  has_many :sponsors, through: :sponsor_associations
  has_many :categories, class_name: '::GoldenKitty::Category', inverse_of: :edition, dependent: :destroy

  explicit_counter_cache :subscribers_count, -> { subscriptions }
  explicit_counter_cache :followers_count, -> { followers }

  SOCIAL_IMAGE_COLUMNS = %w(
    social_image
    social_image_nomination
    social_image_pre_voting
    social_image_voting
    social_image_pre_result
    social_image_result
  ).freeze

  SOCIAL_SHARE_TEXT_COLUMNS = %w(
    social_share_text
    social_text_nomination_started
    social_text_nomination_ended
    social_text_voting_started
    social_text_voting_ended
    social_text_result_announced
  ).freeze

  class << self
    def social_image_columns
      SOCIAL_IMAGE_COLUMNS
    end

    def social_share_text_columns
      SOCIAL_SHARE_TEXT_COLUMNS
    end

    def graphql_type
      'Graph::Types::GoldenKittyEditionType'.safe_constantize
    end
  end

  def phase(preview_for = nil, current_user = nil)
    # Note(Rahul): This is only for admins so we check current_user
    if preview_for.present? && !!current_user&.admin?
      GoldenKitty.phase_preview_for_edition(self, preview_for, current_user)
    else
      GoldenKitty.phase_for_edition(self, current_user)
    end
  end
end
