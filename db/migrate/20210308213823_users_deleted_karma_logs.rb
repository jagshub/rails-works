class UsersDeletedKarmaLogs < ActiveRecord::Migration[5.1]
  def up
    create_table :users_deleted_karma_logs do |t|
      t.references :user, foreign_key: true, null: false
      t.string :subject_type, null: false
      t.integer :karma_value, null: false, default: 0

      t.timestamps
    end
  end

  def down
    drop_table :users_deleted_karma_logs
  end
end
