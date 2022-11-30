class CreateNewsletterSponsors < ActiveRecord::Migration[5.1]
  def change
    create_table :newsletter_sponsors do |t|
      t.references :newsletter, foreign_key: true, null: false
      t.string :image_uuid, null: false
      t.string :link, null: false
      t.text :description_html, null: false
    end
  end
end
