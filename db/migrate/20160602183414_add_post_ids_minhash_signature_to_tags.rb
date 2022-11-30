class AddPostIdsMinhashSignatureToTags < ActiveRecord::Migration
  def change
    add_column :tags, :post_ids_minhash_signature, :hstore
  end
end
