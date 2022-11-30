class AddBodyImageUuidToAdsNewsletterSponsors < ActiveRecord::Migration[6.1]
  def change
    add_column :ads_newsletter_sponsors, :body_image_uuid, :string, null: true
  end
end
