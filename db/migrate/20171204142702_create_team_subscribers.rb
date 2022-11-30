class CreateTeamSubscribers < ActiveRecord::Migration[5.0]
  def change
    create_table :team_subscribers do |t|
      t.references :team, null: false
      t.references :user
      t.string :email, null: false
      t.string :token, null: false
      t.integer :state, null: false, default: 0
      t.integer :device_type, null: false, default: 0
      t.string :os
      t.string :user_agent
      t.string :ip_address

      t.timestamps null: false
    end

    add_foreign_key :team_subscribers, :teams
    add_foreign_key :team_subscribers, :users

    add_index :team_subscribers, [:team_id, :email], unique: true
  end
end
