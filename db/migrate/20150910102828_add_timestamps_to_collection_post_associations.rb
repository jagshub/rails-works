class AddTimestampsToCollectionPostAssociations < ActiveRecord::Migration
  def change
    change_table :collection_post_associations do |t|
      t.timestamps
    end
  end
end
