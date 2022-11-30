class CreateUpcomingPageVariants < ActiveRecord::Migration
  def change
    create_table :upcoming_page_variants do |t|
      t.references :upcoming_page, null: false

      t.integer :kind, null: false

      t.jsonb :who_text
      t.jsonb :what_text
      t.jsonb :why_text
      t.string :logo_uuid
      t.string :brand_color
      t.string :background_image_uuid
      t.jsonb :success_text

      t.timestamps null: false
    end

    add_foreign_key :upcoming_page_variants, :upcoming_pages
    add_index :upcoming_page_variants, %i(upcoming_page_id kind), unique: true
  end
end
