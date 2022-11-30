class AddRelationshipToRelatedPostAssociations < ActiveRecord::Migration
  def change
    change_table :related_post_associations do |t|
      t.integer :relationship, default: 0
    end
  end
end
