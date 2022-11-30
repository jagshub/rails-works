class CreateShipHackathonParticipants < ActiveRecord::Migration
  def change
    create_table :ship_hackathon_participants do |t|
      t.string :client_ip, null: false
      t.references :user, null: true
      t.timestamps null: false
    end

    add_index :ship_hackathon_participants, :client_ip, unique: true
    add_index :ship_hackathon_participants, :user_id, unique: true
    add_foreign_key :ship_hackathon_participants, :users
  end
end
