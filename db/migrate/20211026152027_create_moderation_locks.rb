class CreateModerationLocks < ActiveRecord::Migration[6.1]
  def change
    create_table :moderation_locks do |t|
      t.timestamp :expires_at, null: false
      t.references :subject, polymorphic: true, null: false, index: { unique: true }
      t.references :user, null: false, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
