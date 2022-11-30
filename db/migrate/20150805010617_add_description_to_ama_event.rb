class AddDescriptionToAmaEvent < ActiveRecord::Migration
  def change
    add_column :ama_events, :description, :text
  end
end
