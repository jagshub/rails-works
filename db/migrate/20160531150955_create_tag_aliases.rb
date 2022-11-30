class CreateTagAliases < ActiveRecord::Migration
  def change
    create_table :tag_aliases do |t|
      t.references :tag, index: true, foreign_key: true
      t.text :name

      t.timestamps null: false
    end
  end
end
