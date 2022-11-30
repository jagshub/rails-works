class AddUpdatedAtIndexToVotes < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    # Note(AR): On production, the index should be added before deploying:
    add_index :votes, :updated_at, algorithm: :concurrently, if_not_exists: true
  end
end
