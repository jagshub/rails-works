class CreateCommentAward < ActiveRecord::Migration[6.1]
  def change
    create_table :comment_awards do |t|
      t.string :kind, null: false
      t.belongs_to :comment, null: false, foreign_key: true, index: { unique: true }
      t.references :awarded_by, null: false, foreign_key: { to_table: :users }
      t.references :awarded_to, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :comment_awards, [:awarded_by_id, :awarded_to_id], unique: true
  end
end
