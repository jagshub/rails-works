class CreateBrowserExtensionSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :browser_extension_settings do |t|
      t.references :user, null: true, index: { unique: true }
      t.string :visitor_id, null: true, index: { unique: true }

      t.boolean :background_image_mode, null: false, default: false
      t.boolean :beta_mode, null: false, default: false
      t.boolean :dark_mode, null: false, default: false
      t.string :home_view_variant, null: false, default: 'grid', limit: 32
      t.boolean :show_goals_and_co_working, null: false, default: true
      t.boolean :show_random_product, null: false, default: true

      t.timestamps
    end
  end
end
