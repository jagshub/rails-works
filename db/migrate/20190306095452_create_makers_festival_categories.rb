class CreateMakersFestivalCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :makers_festival_categories do |t|
      t.string :emoji, null: false
      t.string :name, null: false
      t.string :tagline, null: false
      t.references :makers_festival_edition, foreign_key: true, null: false, index: { name: 'index_makers_festival_categories_on_edition_id' }

      t.timestamps
    end
  end
end
