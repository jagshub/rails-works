class RemoveUnusedUpcomingPageColumns < ActiveRecord::Migration
  def change
    remove_column :upcoming_pages, :who_text
    remove_column :upcoming_pages, :what_text
    remove_column :upcoming_pages, :why_text
    remove_column :upcoming_pages, :logo_uuid
    remove_column :upcoming_pages, :brand_color
    remove_column :upcoming_pages, :background_image_uuid
    remove_column :upcoming_page_variants, :success_text
  end
end
