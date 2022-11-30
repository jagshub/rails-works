class AddLogoUuidToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :logo_uuid, :string, null: true
  end
end
