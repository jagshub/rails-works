class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.string :subject, null: false
      t.references :category, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :kind, null: false, default: 0
      t.date :date, null: false
      t.integer :post_ids, null: false, array: true, default: []
      t.jsonb :sections, null: false, array: true, default: []
      t.timestamps null: false
    end
  end
end
