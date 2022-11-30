class ChangeMakersFestTimelineDataType < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column :makers_festival_editions, :registration, :datetime
      change_column :makers_festival_editions, :registration_ended, :datetime
      change_column :makers_festival_editions, :submission, :datetime
      change_column :makers_festival_editions, :submission_ended, :datetime
      change_column :makers_festival_editions, :voting, :datetime
      change_column :makers_festival_editions, :voting_ended, :datetime
      change_column :makers_festival_editions, :result, :datetime
    end
  end
end
