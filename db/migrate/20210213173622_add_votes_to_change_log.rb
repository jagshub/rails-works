class AddVotesToChangeLog < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    safety_assured {
      add_column :change_log_entries, :votes_count, :integer, null: false, default: 0
      add_column :change_log_entries, :credible_votes_count, :integer, null: false, default: 0
    }

    add_index :change_log_entries, :credible_votes_count, algorithm: :concurrently
  end
end
