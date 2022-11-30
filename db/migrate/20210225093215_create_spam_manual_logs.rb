class CreateSpamManualLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :spam_manual_logs do |t|
      t.integer :action, null: false
      t.references :user, foreign_key: true, null: false
      t.references :activity, polymorphic: true, null: true
      t.text :reason, null: true
      t.references :handled_by, foreign_key: { to_table: :users }, null: false

      t.timestamps
    end
  end
end
