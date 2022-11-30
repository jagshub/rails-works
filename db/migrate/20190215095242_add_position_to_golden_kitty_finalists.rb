class AddPositionToGoldenKittyFinalists < ActiveRecord::Migration[5.0]
  def change
    add_column :golden_kitty_finalists, :position, :integer
  end
end
