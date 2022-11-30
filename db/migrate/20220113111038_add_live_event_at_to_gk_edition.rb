class AddLiveEventAtToGkEdition < ActiveRecord::Migration[6.1]
  def change
    add_column :golden_kitty_editions, :live_event_at, :datetime, null: true
  end
end
