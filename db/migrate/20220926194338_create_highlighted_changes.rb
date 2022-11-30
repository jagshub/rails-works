class CreateHighlightedChanges < ActiveRecord::Migration[6.1]
  def change
    create_table :highlighted_changes do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.string :status, null: false, default: 'active'
      t.string :title
      t.text :body
      t.datetime :start_date
      t.datetime :end_date
      t.string :desktop_image_uuid
      t.string :tablet_image_uuid
      t.string :mobile_image_uuid
      t.string :cta_text
      t.string :cta_url

      t.index :status, name: :highlighted_change_status

      t.timestamps
    end
  end
end
