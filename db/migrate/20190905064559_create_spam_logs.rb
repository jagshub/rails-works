class CreateSpamLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :spam_logs do |t|
      t.text :content, null: false
      t.jsonb :more_information, null: false, default: {}
      t.belongs_to :user, index: true, foreign_key: true, null: true
      t.integer :kind, null: false
      t.integer :content_type, index: true, null: false
      t.timestamps null: false
    end
  end
end
