class UpdateFeedDateIndexOnGoal < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    remove_index :goals, :feed_date

    add_index :goals, :feed_date, where: 'hidden_at IS NULL', algorithm: :concurrently
  end

  def down
    remove_index :goals, :feed_date

    add_index :goals, :feed_date, algorithm: :concurrently
  end
end
