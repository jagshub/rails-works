class AddMediaToUpcomingPageVariants < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_variants, :media, :jsonb
  end
end
