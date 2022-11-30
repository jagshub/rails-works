class CreateTeamPostAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :team_post_associations do |t|
      t.integer :team_id, null: false
      t.integer :post_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :team_post_associations, :teams
    add_foreign_key :team_post_associations, :posts

    add_index :team_post_associations, :team_id
    add_index :team_post_associations, [:team_id, :post_id], unique: true
  end
end
