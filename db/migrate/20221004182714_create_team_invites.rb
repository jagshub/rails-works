class CreateTeamInvites < ActiveRecord::Migration[6.1]
  def change
    create_table :team_invites do |t|
      t.references :product, null: false, foreign_key: true
      t.references :referrer, class_name: "User", null: true, foreign_key: { to_table: :users }

      t.string :identity_type, null: false
      t.string :email, null: true
      t.references :user, null: true, foreign_key: true

      t.string :code, null: false, index: true, unique: true
      t.datetime :code_expires_at, null: false

      t.string :status, null: false, default: :pending
      t.datetime :status_changed_at, null: false, default: -> { 'NOW()' }

      t.timestamps
    end
  end
end
