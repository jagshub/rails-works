class DropUnusedTables < ActiveRecord::Migration
  def up
    drop_table :activities # Not used anymore
    drop_table :delayed_jobs # Not used anymore
    drop_table :twitter_tokens # This is all moved to access_tokens
  end

  def down
    create_table :activities
    create_table :delayed_jobs
    create_table :twitter_tokens
  end
end
