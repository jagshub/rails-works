class CreateFounderClubAccessRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :founder_club_access_requests do |t|
      t.string :email, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: true
      t.belongs_to :deal, index: true, foreign_key: false, null: true
      t.string :invite_code, null: false
      t.datetime :received_code_at
      t.datetime :used_code_at
      t.datetime :subscribed_at
      t.timestamps
    end

    add_foreign_key :founder_club_access_requests, :founder_club_deals, column: :deal_id

    add_index :founder_club_access_requests, :invite_code, unique: true
    add_index :founder_club_access_requests, :email, unique: true
  end
end
