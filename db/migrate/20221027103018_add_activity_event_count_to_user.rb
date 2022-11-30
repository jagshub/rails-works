# frozen_string_literal: true

class AddActivityEventCountToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :activity_events_count, :integer, null: true
  end
end
