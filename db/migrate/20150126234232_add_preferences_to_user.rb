class AddPreferencesToUser < ActiveRecord::Migration
  def change
    add_column :users, :preferences, :json, default: {}, null: false
  end
end
