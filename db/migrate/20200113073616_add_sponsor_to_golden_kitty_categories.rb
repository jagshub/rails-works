class AddSponsorToGoldenKittyCategories < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_column :golden_kitty_categories, :sponsor_id, :integer, null: true
      add_foreign_key :golden_kitty_categories, :golden_kitty_sponsors, column: :sponsor_id, index: true
    end
  end
end
