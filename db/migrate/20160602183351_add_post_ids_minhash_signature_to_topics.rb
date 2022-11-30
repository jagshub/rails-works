class AddPostIdsMinhashSignatureToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :post_ids_minhash_signature, :hstore
  end
end
