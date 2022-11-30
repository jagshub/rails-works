class AddWhoWhyWhatHtmlToUpcomingPageVariant < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_variants, :why_html, :text
    add_column :upcoming_page_variants, :what_html, :text
    add_column :upcoming_page_variants, :who_html, :text
  end
end
