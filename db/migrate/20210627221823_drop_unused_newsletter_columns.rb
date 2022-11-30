class DropUnusedNewsletterColumns < ActiveRecord::Migration[5.2]
  def change
    safety_assured { remove_column :ads_newsletters, :deal_text }
  end
end
