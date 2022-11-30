class ChangeAdsNewsletterIdToNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :ads_newsletters, :newsletter_id, true
  end
end
