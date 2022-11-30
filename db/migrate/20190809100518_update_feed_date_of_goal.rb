class UpdateFeedDateOfGoal < ActiveRecord::Migration[5.1]
  def up
    change_column :goals, :feed_date, :date, null: false, default: -> { 'CURRENT_TIMESTAMP' }

    add_index :goals, :feed_date
  end

  def down
    change_column :goals, :feed_date, :date, null: true

    remove_index :goals, :feed_date
  end
end
