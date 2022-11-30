class AddAmaEventScheduleImage < ActiveRecord::Migration
  def change
    add_column :ama_events, :schedule_image_uuid, :uuid, null: true

    execute 'UPDATE ama_events SET schedule_image_uuid = user_image_uuid FROM ama_event_guest_associations WHERE ama_event_id = ama_events.id'
  end

  def down
    remove_column :ama_events, :schedule_image_uuid
  end
end
