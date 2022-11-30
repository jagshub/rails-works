class AddAmaEventDetails < ActiveRecord::Migration
  class AmaEvent < ApplicationRecord
    include Sluggable
    sluggable

    has_many :ama_event_guest_associations
  end

  class AmaEventGuestAssociation < ApplicationRecord
  end

  def up
    add_column :ama_events, :slug, :text, null: true, unique: true
    add_column :ama_events, :comment_count, :integer, null: false, default: 0
    add_column :ama_events, :header_media_uuid, :uuid, null: true
    add_column :ama_events, :starts_at, :timestamp
    add_column :ama_events, :ends_at, :timestamp
    change_column_null :ama_events, :event_date, true

    # Fill out event start times
    AmaEvent.connection.execute 'UPDATE ama_events SET starts_at = event_date'

    # Generate slugs
    AmaEvent.all.each(&:save!)

    change_column_null :ama_events, :slug, false

    create_table :ama_event_guest_associations do |t|
      t.references :ama_event, null: false, index: true
      t.references :user, null: true
      t.uuid :user_image_uuid, null: true
    end

    AmaEvent.all.each do |ama_event|
      next unless ama_event.maker_image_uuid.present?

      ama_event.ama_event_guest_associations.create! user_image_uuid: ama_event.maker_image_uuid
    end
  end

  def down
    remove_column :ama_events, :slug
    remove_column :ama_events, :comment_count
    remove_column :ama_events, :header_media_uuid
    remove_column :ama_events, :starts_at
    remove_column :ama_events, :ends_at
    change_column_null :ama_events, :event_date, false

    drop_table :ama_event_guest_associations
  end
end
