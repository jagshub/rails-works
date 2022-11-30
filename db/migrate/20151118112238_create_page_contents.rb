class CreatePageContents < ActiveRecord::Migration
  def change
    create_table :page_contents do |t|
      t.text :subject_type, null: true
      t.integer :subject_id, null: true
      t.references :page_section, null: false
      t.integer :priority, default: 0, null: false
      t.timestamps null: false
    end
  end
end
