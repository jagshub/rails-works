class CreateNewPageContents < ActiveRecord::Migration[5.1]
  def change
    create_table :page_contents do |t|
      t.string :page_key, null: false
      t.string :element_key, null: false
      t.text :content, null: true
      t.string :image_uuid, null: true

      t.timestamps
    end

    add_index :page_contents, :page_key
  end
end
