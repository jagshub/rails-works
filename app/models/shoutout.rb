# frozen_string_literal: true

# == Schema Information
#
# Table name: shoutouts
#
#  id                   :integer          not null, primary key
#  user_id              :integer          not null
#  body                 :text             not null
#  trashed_at           :datetime
#  votes_count          :integer          default(0), not null
#  credible_votes_count :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  priority             :integer          default(0), not null
#
# Indexes
#
#  index_shoutouts_on_trashed_at  (trashed_at)
#  index_shoutouts_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Shoutout < ApplicationRecord
  include Trashable
  include Mentionable
  include Votable
  include ChronologicalOrder
  include Prioritisable

  belongs_to :user

  validates :body, presence: true

  scope :by_year, ->(year) { where('created_at >= ? AND created_at <= ?', "12-01-#{ year.to_i }", "11-01-#{ year.to_i + 1 }") }

  def self.ransackable_scopes(_auth_object = nil)
    %i(by_year)
  end

  def year
    if created_at.month == 12
      created_at.year
    else
      created_at.year - 1
    end
  end
end
