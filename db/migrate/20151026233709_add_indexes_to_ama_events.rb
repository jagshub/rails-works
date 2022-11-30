class AddIndexesToAmaEvents < ActiveRecord::Migration
  def change
    add_index :ama_events, :slug
    add_index :ama_events, :starts_at
  end
end
