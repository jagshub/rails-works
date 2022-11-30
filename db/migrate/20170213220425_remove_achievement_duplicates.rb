class RemoveAchievementDuplicates < ActiveRecord::Migration
  # Note (Mike Coutermarsh): Finds and removes duplicate records from user_achievement_associations
  def delete_duplicates_query
    <<-SQL
    DELETE FROM user_achievement_associations
    WHERE id IN (SELECT id
                 FROM (SELECT id,
                       ROW_NUMBER() OVER (partition BY user_id, achievement_id ORDER BY id) AS row_number
                 FROM user_achievement_associations) t
                 WHERE t.row_number > 1);
    SQL
  end

  def change
    ActiveRecord::Base.connection.exec_query delete_duplicates_query
    add_index :user_achievement_associations, [:user_id, :achievement_id], unique: true, name: 'index_user_achievement_assoc_on_user_id_and_achievement_id'
  end
end
