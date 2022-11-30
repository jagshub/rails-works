class RenameAdsNewsletterSendsCount < ActiveRecord::Migration[5.1]
  def change
    safety_assured {
      rename_column :ads_newsletters, :sends_count, :sents_count
    }
  end
end
