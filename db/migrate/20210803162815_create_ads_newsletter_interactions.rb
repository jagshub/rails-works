class CreateAdsNewsletterInteractions < ActiveRecord::Migration[5.2]
  def change
    create_table :ads_newsletter_interactions do |t|
      t.references :ads_newsletter, null: false, index: true
      t.references :user, null: true, index: true
      t.string :kind, null: false
      t.string :user_agent, null: true
      t.boolean :is_bot, null: false, default: false

      t.timestamps null: false
    end
  end
end
