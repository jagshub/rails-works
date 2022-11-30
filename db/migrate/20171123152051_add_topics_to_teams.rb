class AddTopicsToTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :team_topic_associations do |t|
      t.integer :team_id, null: false
      t.integer :topic_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :team_topic_associations, :teams
    add_foreign_key :team_topic_associations, :topics

    add_index :team_topic_associations, [:team_id, :topic_id], unique: true
  end
end
