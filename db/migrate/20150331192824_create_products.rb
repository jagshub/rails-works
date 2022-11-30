class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :screenshot_url
      t.boolean :verified, default: false, null: false

      t.timestamps null: false
    end
  end
end

