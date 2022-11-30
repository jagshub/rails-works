class AddUpcomingEnabledFlagToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :upcoming_enabled, :boolean, null: false, default: true
  end
end
