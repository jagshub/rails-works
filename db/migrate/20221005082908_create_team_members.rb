class CreateTeamMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :team_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :referrer, polymorphic: true, null: false

      t.string :role, null: false
      t.string :position, null: true
      t.string :team_email, null: true

      t.string :status, null: false, default: :active
      t.datetime :status_changed_at, null: false, default: -> { 'NOW()' }

      t.timestamps
    end

    add_index :team_members, [:user_id, :product_id], unique: true
  end
end
