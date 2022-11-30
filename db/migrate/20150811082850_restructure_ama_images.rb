class RestructureAmaImages < ActiveRecord::Migration
  def up
    rename_column :ama_events, :header_media_uuid, :background_image_uuid
    remove_column :ama_events, :maker_image_uuid
  end

  def down
    rename_column :ama_events, :background_image_uuid, :header_media_uuid
    add_column :ama_events, :maker_image_uuid, :uuid
  end
end
