class MigrateMakerSuggestionsFromInvites < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO maker_suggestions (approved_by_id, invited_by_id, post_id, maker_username, created_at, updated_at)
      (SELECT user_id AS approved_by_id,
              user_id AS invited_by_id,
              maker_of_post_id AS post_id,
              username AS maker_username,
              created_at,
              updated_at
       FROM invites
       WHERE maker_of_post_id IS NOT NULL
         AND invited_id IS NULL)
    SQL

    remove_column :invites, :maker_of_post_id
  end

  def down
    add_column :invites, :maker_of_post_id, :integer
  end
end
