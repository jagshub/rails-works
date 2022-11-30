class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :user, index: true, foreign_key: false
      t.text :title, null: false
      t.text :body, null: false
      t.integer :recommendations_count, null: false, default: 0

      t.timestamps null: false
    end
  end
end
