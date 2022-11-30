class AllowAmaEventsWithoutThumbnail < ActiveRecord::Migration
  def change
    change_column_null :ama_events, :thumbnail_image_uuid, true
  end
end
