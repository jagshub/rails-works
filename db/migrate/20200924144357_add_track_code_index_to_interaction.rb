class AddTrackCodeIndexToInteraction < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :ads_interactions, :track_code, algorithm: :concurrently
    add_index :ads_interactions, :user_id, algorithm: :concurrently
  end
end
