class AddSubscriberCountToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :subscriber_count, :integer, default: 0, null: false
  end
end
