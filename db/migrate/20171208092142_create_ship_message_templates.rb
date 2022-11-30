class CreateShipMessageTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_message_templates do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.timestamps null: false
    end

    add_index :ship_message_templates, :title, unique: true
  end
end
