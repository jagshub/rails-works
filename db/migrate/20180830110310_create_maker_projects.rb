class CreateMakerProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :maker_projects do |t|
      t.references :user, null: true, foreign_key: true, index: true
      t.references :upcoming_page, foreign_key: true, index: { unique: true }
      t.string :name, null: false
      t.string :tagline, null: false
      t.string :image_uuid
      t.boolean :looking_for_other_makers, null: false, default: false
      t.timestamps null: false
    end
  end
end
