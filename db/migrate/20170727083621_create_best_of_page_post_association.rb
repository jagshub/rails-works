class CreateBestOfPagePostAssociation < ActiveRecord::Migration
  def change
    create_table :best_of_page_post_associations do |t|
      t.references :post, null: false
      t.references :best_of_page, null: false
      t.timestamps null: false
    end

    add_index :best_of_page_post_associations, %i(post_id best_of_page_id), unique: true, name: 'index_best_post_associations_on_best_of_page_id_and_post_id'
  end
end
