class AddAdFieldsToChannels < ActiveRecord::Migration[6.1]
  def change
    add_column :ads_channels, :name, :string, null: true
    add_column :ads_channels, :tagline, :string, null: true
    add_column :ads_channels, :thumbnail_uuid, :string, null: true
    add_column :ads_channels, :cta_text, :string, null: true
  end
end
