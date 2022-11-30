class CreateCollectionCuratorAssociations < ActiveRecord::Migration
  def change
    create_table :collection_curator_associations do |t|
      t.references :user, null: false
      t.references :collection, null: false
      t.timestamps null: false
    end

    add_index :collection_curator_associations, %i(user_id collection_id), unique: true, name: 'index_collection_curator_associations_on_user_and_collection'
  end
end


