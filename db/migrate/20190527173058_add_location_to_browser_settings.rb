class AddLocationToBrowserSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :browser_extension_settings, :locality, :string
  end
end
