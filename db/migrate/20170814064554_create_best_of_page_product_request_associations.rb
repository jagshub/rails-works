class CreateBestOfPageProductRequestAssociations < ActiveRecord::Migration
  def change
    create_table :best_of_page_product_request_associations do |t|
      t.references :product_request, null: false
      t.references :best_of_page, null: false
      t.timestamps null: false
    end

    add_index :best_of_page_product_request_associations, %i(product_request_id best_of_page_id), unique: true, name: 'index_best_request_assocs_on_best_id_and_request_id'
  end
end
