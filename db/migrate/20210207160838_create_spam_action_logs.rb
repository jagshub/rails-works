class CreateSpamActionLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :spam_action_logs do |t|
      t.references :subject, polymorphic: true, null: false
      t.references :user, foreign_key: true, null: false
      t.boolean :spam, null: false
      t.boolean :false_positive, null: false, default: false
      t.string :action_taken_on_activity, null: true
      t.string :action_taken_on_actor, null: true
      t.references :spam_ruleset, foreign_key: true, null: false

      t.timestamps
    end
  end
end
