class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.text :subject_type, null: false
      t.integer :subject_id, null: false
      t.integer :user_id, null: false
      t.boolean :credible, null: false, default: true
      t.boolean :sandboxed, null: false, default: false

      t.timestamps
    end

    add_index :votes, [:subject_type, :subject_id, :credible]
    add_index :votes, [:user_id, :subject_type, :subject_id], unique: true
  end
end
