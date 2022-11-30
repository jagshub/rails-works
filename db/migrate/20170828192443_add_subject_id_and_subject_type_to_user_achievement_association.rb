class AddSubjectIdAndSubjectTypeToUserAchievementAssociation < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_column :user_achievement_associations, :subject_id, :integer, null: true
    add_column :user_achievement_associations, :subject_type, :string, null: true

    add_column :user_achievement_associations, :target_id, :integer, null: true
    add_column :user_achievement_associations, :target_type, :string, null: true

    add_index :user_achievement_associations, [:achievement_id, :user_id, :subject_type, :subject_id, :target_type, :target_id], unique: true, name: 'index_user_achievement_assoc_on_achievement_user_subject_target'
    remove_index :user_achievement_associations, name: 'index_user_achievement_assoc_on_user_id_and_achievement_id'
  end
end
