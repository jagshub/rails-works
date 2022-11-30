class ChangeImageUuidColumnOnProductMedia < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column :product_media, :image_uuid, :string, null: false
    end
  end
end
