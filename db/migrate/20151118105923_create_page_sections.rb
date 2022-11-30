class CreatePageSections < ActiveRecord::Migration
  def change
    create_table :page_sections do |t|
      t.integer :section_type, default: 0, null: true
      t.integer :page, default: 0, null: true
      t.integer :priority, default: 0, null: false
      t.timestamps null: false
    end
  end
end
