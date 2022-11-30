class AddModerationLogs < ActiveRecord::Migration
  def change
    create_table :moderation_logs do |t|
      t.references :reference, polymorphic: true, null: false
      t.references :moderator, null: false
      t.text :message, null: false
      t.timestamps null: false
    end
  end
end
