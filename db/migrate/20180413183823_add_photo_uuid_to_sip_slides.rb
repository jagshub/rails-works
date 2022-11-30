class AddPhotoUuidToSipSlides < ActiveRecord::Migration[5.0]
  def change
    add_column :sip_slides, :photo_uuid, :uuid
  end
end
