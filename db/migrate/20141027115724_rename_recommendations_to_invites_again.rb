class RenameRecommendationsToInvitesAgain < ActiveRecord::Migration
  def change
    remove_index :recommendations, column: :recommended_id, name: "index_recommendations_on_recommended_id"
    remove_index :recommendations, column: :user_id, name: "index_recommendations_on_user_id"
    remove_index :recommendations, column: :username, name: "index_recommendations_on_username"

    rename_table :recommendations, :invites
    rename_column :invites, :recommended_id, :invited_id

    add_index :invites, [:invited_id], name: "index_invites_on_invited_id"
    add_index :invites, [:user_id], name: "index_invites_on_user_id"
    add_index :invites, [:username], name: "index_invites_on_username"

    rename_column :users, :recommendations_left, :invites_left

    remove_index :users, column: :recommended_by_id, name: "index_users_on_recommended_by_id"
    rename_column :users, :recommended_by_id, :invited_by_id
    add_index :users, [:invited_by_id], name: "index_users_on_invited_by_id", using: :btree
  end
end
