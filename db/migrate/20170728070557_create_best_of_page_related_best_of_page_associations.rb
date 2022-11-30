class CreateBestOfPageRelatedBestOfPageAssociations < ActiveRecord::Migration
  def change
    create_table :best_of_page_related_best_of_page_associations do |t|
      t.references :best_of_page, null: false
      t.references :related_best_of_page, references: :best_of_pages
      t.timestamps null: false
    end

    add_index :best_of_page_related_best_of_page_associations, %i(related_best_of_page_id best_of_page_id), unique: true, name: 'index_best_related_assocs_on_best_of_page_id_and_related_id'
  end
end
