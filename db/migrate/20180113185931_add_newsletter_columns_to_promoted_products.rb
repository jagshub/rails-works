class AddNewsletterColumnsToPromotedProducts < ActiveRecord::Migration[5.0]
  def change
    add_reference :promoted_products, :newsletter, foreign_key: true, index: { unique: true }
    add_column :promoted_products, :newsletter_title, :string
    add_column :promoted_products, :newsletter_description, :text
    add_column :promoted_products, :newsletter_link, :text
    add_column :promoted_products, :newsletter_image_uuid, :string
  end
end
