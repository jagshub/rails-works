class AddCtaToNewsletterSponsor < ActiveRecord::Migration[5.2]
  def change
    add_column :newsletter_sponsors, :cta, :string, null: true
  end
end
