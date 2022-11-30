class AddCountersToAdsNewsletterSponsors < ActiveRecord::Migration[5.2]
  def change
    add_column :ads_newsletter_sponsors, :opens_count, :integer, default: 0, null: false
    add_column :ads_newsletter_sponsors, :clicks_count, :integer, default: 0, null: false
    add_column :ads_newsletter_sponsors, :sents_count, :integer, default: 0, null: false
  end
end
