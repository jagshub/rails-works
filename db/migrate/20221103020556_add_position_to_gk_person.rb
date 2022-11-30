class AddPositionToGkPerson < ActiveRecord::Migration[6.1]
  def change
    add_column :golden_kitty_people, :position, :integer
  end
end
