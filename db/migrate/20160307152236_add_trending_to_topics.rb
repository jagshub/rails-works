class AddTrendingToTopics < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_column :topics, :trending, :boolean, default: false, null: false
    add_index :topics, :trending, algorithm: :concurrently
  end
end
