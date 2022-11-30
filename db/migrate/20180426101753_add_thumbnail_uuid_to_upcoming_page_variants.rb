class AddThumbnailUuidToUpcomingPageVariants < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_variants, :thumbnail_uuid, :string, null: true
  end
end
