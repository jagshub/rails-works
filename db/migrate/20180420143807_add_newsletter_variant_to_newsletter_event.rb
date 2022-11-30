class AddNewsletterVariantToNewsletterEvent < ActiveRecord::Migration[5.0]
  def change
    add_reference :newsletter_events, :newsletter_variant, foreign_key: true
  end
end
