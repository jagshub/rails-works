# frozen_string_literal: true

class AddChannelIdAndKindIndexOnAdsInteractions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_index :ads_interactions, %i(channel_id kind), algorithm: :concurrently
    remove_index :ads_interactions, :channel_id
  end

  def down
    add_index :ads_interactions, :channel_id, algorithm: :concurrently
    remove_index :ads_interactions, %i(channel_id kind)
  end
end
