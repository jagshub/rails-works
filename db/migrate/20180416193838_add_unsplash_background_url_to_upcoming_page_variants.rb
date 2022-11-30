class AddUnsplashBackgroundUrlToUpcomingPageVariants < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_variants, :unsplash_background_url, :string
  end
end
