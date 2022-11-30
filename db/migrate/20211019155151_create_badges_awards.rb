class CreateBadgesAwards < ActiveRecord::Migration[6.1]
  def change
    create_table :badges_awards do |t|
      t.string :identifier, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :description, null: false
      t.string :image_uuid, null: false
      t.boolean :active, null: false, default: false
      t.timestamps
    end
  end
end
