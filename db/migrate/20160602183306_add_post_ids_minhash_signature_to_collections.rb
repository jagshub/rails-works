class AddPostIdsMinhashSignatureToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :post_ids_minhash_signature, :hstore
  end
end
