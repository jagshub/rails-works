class CreateBestOfPages < ActiveRecord::Migration
  def change
    create_table :best_of_pages do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description, null: false
      t.string :search_query, null: false
      t.string :thumbnail_uuid
      t.timestamps null: false
    end

    add_index :best_of_pages, :name, unique: true
    add_index :best_of_pages, :slug, unique: true
  end
end
