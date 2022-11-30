class AddIndicesToAdsNewsletterTables < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :ads_newsletters, %i(active weight), algorithm: :concurrently
    add_index :ads_newsletter_sponsors, %i(active weight), algorithm: :concurrently
  end
end
