class CreateSpamReports < ActiveRecord::Migration[5.1]
  def change
    create_table :spam_reports do |t|
      t.references :spam_action_log, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.integer :check, null: false
      t.integer :action_taken, null: true
      t.references :handled_by, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end
  end
end
