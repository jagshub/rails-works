class AddNewsletterGroupToBanners < ActiveRecord::Migration
  def change
    change_table :banners do |t|
      t.string :newsletter_group
    end
  end
end
