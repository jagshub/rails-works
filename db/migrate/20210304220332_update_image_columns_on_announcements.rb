class UpdateImageColumnsOnAnnouncements < ActiveRecord::Migration[5.1]
  def up
    safety_assured {
      rename_column :announcements, :image_uuid, :image_desktop_uuid

      add_column :announcements, :image_tablet_uuid, :string, null: true
      add_column :announcements, :image_mobile_uuid, :string, null: true
    }
  end

  def down
    safety_assured {
      rename_column :announcements, :image_desktop_uuid, :image_uuid

      remove_column :announcements, :image_tablet_uuid
      remove_column :announcements, :image_mobile_uuid
    }
  end
end
