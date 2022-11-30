class AddIndexToTrackCode < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :promoted_analytics, :track_code, using: 'btree', algorithm: :concurrently
  end
end
