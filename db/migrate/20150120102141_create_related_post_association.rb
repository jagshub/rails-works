class CreateRelatedPostAssociation < ActiveRecord::Migration
  def change
    create_table :related_post_associations do |t|
      t.references :post, index: true, null: false
      t.references :related_post, null: false
      t.references :user, null: false

      t.timestamps null: false
    end

    add_index :related_post_associations, [:post_id, :related_post_id], unique: true
  end
end
