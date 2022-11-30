class CreateMeetupTags < ActiveRecord::Migration[5.0]
  def change
    create_table :meetup_event_tags do |t|
      t.citext :name, null: false
      t.integer :meetup_events_count, null: false, default: 0
      t.timestamps null: false
    end

    create_table :meetup_event_tag_associations do |t|
      t.integer :meetup_event_id, null: false
      t.integer :meetup_event_tag_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :meetup_event_tag_associations, :meetup_events
    add_foreign_key :meetup_event_tag_associations, :meetup_event_tags

    add_index :meetup_event_tag_associations, [:meetup_event_id, :meetup_event_tag_id], unique: true, name: :index_meetup_event_tag_associations

    add_index :meetup_event_tags, :name, using: :gin, order: { name: :gin_trgm_ops }
  end
end
