class AddDescriptionToCollectionPostAssiciations < ActiveRecord::Migration
  def change
    change_table :collection_post_associations do |t|
      t.column :description, :text
    end
  end
end
