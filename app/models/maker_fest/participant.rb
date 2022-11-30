# frozen_string_literal: true

# == Schema Information
#
# Table name: maker_fest_participants
#
#  id                   :integer          not null, primary key
#  category_slug        :integer          default("social"), not null
#  user_id              :integer          not null
#  upcoming_page_id     :integer          not null
#  votes_count          :integer          default(0), not null
#  credible_votes_count :integer          default(0), not null
#  external_link        :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_maker_fest_participants_on_upcoming_page_id  (upcoming_page_id)
#  index_maker_fest_participants_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_id => upcoming_pages.id)
#  fk_rails_...  (user_id => users.id)
#

class MakerFest::Participant < ApplicationRecord
  include Namespaceable
  include Votable

  belongs_to :user
  belongs_to :upcoming_page

  validates :category_slug, :user_id, :upcoming_page_id, :external_link, presence: true

  enum category_slug: {
    social: 0,
    voice: 1,
    health: 2,
    inclusion: 3,
    brain: 4,
    remote: 5,
    other: 6,
  }
end
