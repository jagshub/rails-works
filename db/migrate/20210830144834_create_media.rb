class CreateMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :media do |t|
      t.references :user, null: true, index: 'IS NOT NULL'
      t.references :subject, polymorphic: true, index: true, null: false
      t.string :uuid, null: false
      t.string :kind, null: false

      t.integer :priority, null: false, default: 0
      t.integer :original_width, null: false
      t.integer :original_height, null: false

      t.json :metadata
      t.text :original_url

      t.timestamps
    end
  end
end
