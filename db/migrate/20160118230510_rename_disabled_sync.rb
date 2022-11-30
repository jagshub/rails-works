class RenameDisabledSync < ActiveRecord::Migration
  def up
    rename_table 'disabled_twitter_syncs', 'disabled_friend_syncs'
    execute 'CREATE VIEW disabled_twitter_syncs AS SELECT * FROM disabled_friend_syncs'
  end

  def down
    execute 'DROP VIEW disabled_twitter_syncs'
    rename_table 'disabled_friend_syncs', 'disabled_twitter_syncs'
  end
end
