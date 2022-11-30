class AddUsageDurationToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :usage_duration, :integer
  end
end
