class AddSeoFieldsToUpcomingPages < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_pages, :seo_title, :string
    add_column :upcoming_pages, :seo_description, :string
    add_column :upcoming_pages, :seo_image_uuid, :string
  end
end
