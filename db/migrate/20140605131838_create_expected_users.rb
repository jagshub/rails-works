class CreateExpectedUsers < ActiveRecord::Migration
  def change
    create_table :expected_users do |t|
      t.integer :role, default: 0, nil: false
      t.string :username, nil: false

      t.timestamps
    end
  end
end
