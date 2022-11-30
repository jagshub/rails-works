class CreateTeamRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :team_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :moderator, class_name: "User", null: true, foreign_key: { to_table: :users }

      t.string :team_email, null: true
      t.string :approval_type, null: true

      t.string :status, null: false, default: :pending
      t.datetime :status_changed_at, null: false, default: -> { 'NOW()' }

      t.timestamps
    end
  end
end
