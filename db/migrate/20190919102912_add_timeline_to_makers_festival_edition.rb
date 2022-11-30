class AddTimelineToMakersFestivalEdition < ActiveRecord::Migration[5.1]
  def change
    add_column :makers_festival_editions, :registration, :date
    add_column :makers_festival_editions, :registration_ended, :date
    add_column :makers_festival_editions, :submission, :date
    add_column :makers_festival_editions, :submission_ended, :date
    add_column :makers_festival_editions, :voting, :date
    add_column :makers_festival_editions, :voting_ended, :date
    add_column :makers_festival_editions, :result, :date
  end
end
