class AddIntroBackgroundUuidToSips < ActiveRecord::Migration[5.0]
  def change
    add_column :sips, :intro_background_uuid, :uuid
  end
end
