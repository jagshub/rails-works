class AddBodyImageToNewsletterSponsors < ActiveRecord::Migration[5.2]
  def change
    add_column :newsletter_sponsors, :body_image_uuid, :string
  end
end
