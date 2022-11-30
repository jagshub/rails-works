class CreateShipInviteCodes < ActiveRecord::Migration
  def change
    create_table :ship_invite_codes do |t|
      t.integer :discount_value, null: false, default: 0
      t.string :code, null: false, unique: true
      t.string :image_uuid
      t.text :description, null: false
      t.timestamps null: false
    end
  end
end
