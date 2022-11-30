class CreateTeamThankfulToUserAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :team_thankful_to_user_associations do |t|
      t.references :team, null: false, index: true, foreign_key: true
      t.references :user, null: false, index: true, foreign_key: true
      t.string :comment
      t.timestamps null: false
    end

    add_index :team_thankful_to_user_associations, %i(team_id user_id), unique: true
  end
end
