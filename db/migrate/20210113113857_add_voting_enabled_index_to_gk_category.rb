class AddVotingEnabledIndexToGkCategory < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :golden_kitty_categories, :voting_enabled_at, algorithm: :concurrently
  end
end
