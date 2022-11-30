class AddSlugToGoldenKittyCategories < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_column :golden_kitty_categories, :slug, :string, null: true

    add_index :golden_kitty_categories, %i(slug year), unique: true, algorithm: :concurrently
  end
end
