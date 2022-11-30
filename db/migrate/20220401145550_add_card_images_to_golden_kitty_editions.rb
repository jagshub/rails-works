class AddCardImagesToGoldenKittyEditions < ActiveRecord::Migration[6.1]
  def change
    add_column :golden_kitty_editions, :card_image_uuid, :string
  end
end
