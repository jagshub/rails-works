# frozen_string_literal: true

# == Schema Information
#
# Table name: makers_festival_participants
#
#  id                          :integer          not null, primary key
#  user_id                     :integer          not null
#  makers_festival_category_id :integer          not null
#  external_link               :string
#  votes_count                 :integer          default(0), not null
#  credible_votes_count        :integer          default(0), not null
#  project_details             :jsonb            not null
#  finalist                    :boolean          default(FALSE), not null
#  winner                      :boolean          default(FALSE), not null
#  position                    :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  receive_tc_resources        :boolean          default(FALSE), not null
#
# Indexes
#
#  index_makers_festival_participant_on_category_id  (makers_festival_category_id)
#  index_makers_festival_participants_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (makers_festival_category_id => makers_festival_categories.id)
#  fk_rails_...  (user_id => users.id)
#

class MakersFestival::Participant < ApplicationRecord
  include Namespaceable
  include Storext.model
  include Votable

  validates :position, presence: { if: :winner? }, uniqueness: { allow_blank: true, scope: :makers_festival_category, message: 'already used for this category!' }, inclusion: { allow_blank: true, in: 1..3 }

  belongs_to :user, inverse_of: :makers_festival_participant
  belongs_to :makers_festival_category, class_name: '::MakersFestival::Category', inverse_of: :participants

  has_many :maker_associations, class_name: '::MakersFestival::Maker', foreign_key: 'makers_festival_participant_id', inverse_of: :makers_festival_participant, dependent: :destroy
  has_many :makers, through: :maker_associations, source: :user

  store_attributes :project_details do
    project_name String, default: nil
    project_tagline String, default: nil
    project_thumbnail String, default: nil
    project_article_link String, default: nil
    snapchat_app_id String, default: nil
    snapchat_app_video_link String, default: nil
    snapchat_username String, default: nil
  end
end
