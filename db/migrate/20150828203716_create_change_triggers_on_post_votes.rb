class CreateChangeTriggersOnPostVotes < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TRIGGER post_votes_change_trigger
      BEFORE INSERT OR UPDATE OR DELETE
      ON post_votes FOR EACH ROW
      EXECUTE PROCEDURE change_trigger_v2();
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS post_votes_change_trigger ON comments CASCADE;
    SQL
  end
end
