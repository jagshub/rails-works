class CreatePrivateMessages < ActiveRecord::Migration
  def change
    create_table :private_messages do |t|
      t.integer :from_user_id, null: false
      t.integer :to_user_id, null: false
      t.text :encrypted_body, null: false

      t.timestamps null: false
    end

    add_index :private_messages, :from_user_id
    add_index :private_messages, :to_user_id
  end
end
