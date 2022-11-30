# frozen_string_literal: true

# == Schema Information
#
# Table name: makers_festival_editions
#
#  id                      :integer          not null, primary key
#  start_date              :date             not null
#  sponsor                 :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  discussions_count       :integer          default(0), not null
#  slug                    :string
#  name                    :string
#  tagline                 :string
#  description             :text
#  prizes                  :text
#  discussion_preview_uuid :string
#  embed_url               :string
#  banner_uuid             :string
#  social_banner_uuid      :string
#  result_url              :string
#  registration            :datetime
#  registration_ended      :datetime
#  submission              :datetime
#  submission_ended        :datetime
#  voting                  :datetime
#  voting_ended            :datetime
#  result                  :datetime
#  maker_group_id          :bigint(8)
#  share_text              :text
#
# Indexes
#
#  index_makers_festival_editions_on_maker_group_id  (maker_group_id)
#  index_makers_festival_editions_on_slug            (slug) UNIQUE
#  index_makers_festival_editions_on_start_date      (start_date)
#
# Foreign Keys
#
#  fk_rails_...  (maker_group_id => maker_groups.id)
#

class MakersFestival::Edition < ApplicationRecord
  include Namespaceable
  include Discussable
  include Sluggable
  include Uploadable

  sluggable
  uploadable :discussion_preview
  uploadable :banner
  uploadable :social_banner

  validates :name, presence: true
  validates :tagline, presence: true
  validates :description, presence: true
  validates :prizes, presence: true
  validates :start_date, presence: true

  belongs_to :maker_group, class_name: '::MakerGroup', optional: true, inverse_of: :makers_festival_edition
  has_many :categories, class_name: '::MakersFestival::Category', foreign_key: 'makers_festival_edition_id', inverse_of: :makers_festival_edition, dependent: :destroy

  def participant?(user)
    return false if user.blank?

    ::MakersFestival::Maker.joins(makers_festival_participant: :makers_festival_category)
                           .where('makers_festival_participants.makers_festival_category_id IN (?)', category_ids)
                           .exists?(user_id: user.id)
  end
end
