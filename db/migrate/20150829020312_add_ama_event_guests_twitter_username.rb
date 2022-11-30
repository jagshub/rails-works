class AddAmaEventGuestsTwitterUsername < ActiveRecord::Migration
  def change
    add_column :ama_events, :twitter_username, :text, null: true
  end
end
