class DropOldVoteTables < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP TABLE post_vote_check_results CASCADE;
      DROP TABLE post_vote_infos CASCADE;
      DROP TABLE comment_votes CASCADE;
      DROP TABLE post_votes CASCADE;
      DROP FUNCTION IF EXISTS legacy_post_vote_sync() CASCADE;
      DROP FUNCTION IF EXISTS legacy_comment_vote_sync() CASCADE;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
