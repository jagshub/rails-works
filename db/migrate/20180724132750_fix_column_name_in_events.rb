class FixColumnNameInEvents < ActiveRecord::Migration[5.0]
  def change
    rename_table :events, :meetup_events

    add_column :meetup_events, :created_at, :datetime, null: true
    add_column :meetup_events, :updated_at, :datetime, null: true

    rename_column :meetup_events, :suscriber_count, :subscribers_count
  end
end
