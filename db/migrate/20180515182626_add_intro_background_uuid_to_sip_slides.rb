class AddIntroBackgroundUuidToSipSlides < ActiveRecord::Migration[5.0]
  def change
    add_column :sip_slides, :intro_background_uuid, :uuid
  end
end
