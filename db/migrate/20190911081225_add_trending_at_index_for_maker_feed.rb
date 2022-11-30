class AddTrendingAtIndexForMakerFeed < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :goals, :trending_at, algorithm: :concurrently, where: 'hidden_at IS NULL AND trending_at IS NOT NULL'
    add_index :discussion_threads, :trending_at, algorithm: :concurrently, where: 'hidden_at IS NULL AND trending_at IS NOT NULL'
  end
end
