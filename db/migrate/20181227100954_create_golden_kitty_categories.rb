class CreateGoldenKittyCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :golden_kitty_categories do |t|
      t.string :name, null: false
      t.string :tagline, null: false
      t.string :emoji, null: false
      t.string :nomination_question, null: false
      t.integer :year, null: false, default: 0

      t.timestamps
    end
  end
end
