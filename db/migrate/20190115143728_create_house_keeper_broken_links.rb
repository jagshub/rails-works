class CreateHouseKeeperBrokenLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :house_keeper_broken_links do |t|
      t.references :post, foreign_key: true, null: false

      t.timestamps
    end
  end
end
