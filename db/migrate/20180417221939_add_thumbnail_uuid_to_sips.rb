class AddThumbnailUuidToSips < ActiveRecord::Migration[5.0]
  def change
    add_column :sips, :thumbnail_uuid, :uuid
  end
end
