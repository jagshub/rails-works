class CreateGoldenKittyFacts < ActiveRecord::Migration[5.1]
  def change
    create_table :golden_kitty_facts do |t|
      t.string :image_uuid, null: false
      t.string :description, null: false
      t.belongs_to :category, index: true, foreign_key: {to_table:'golden_kitty_categories'}, null: false

      t.timestamps
    end
  end
end
