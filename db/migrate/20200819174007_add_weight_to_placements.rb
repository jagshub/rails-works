class AddWeightToPlacements < ActiveRecord::Migration[5.1]
  def change
    safety_assured {
      add_column :ads_placements, :weight, :integer, default: 0, null: false
      add_index :ads_placements, :weight
      add_index :ads_placements, :active
    }
  end
end
