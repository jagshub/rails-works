class CreateMarketingNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :marketing_notifications do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.string :user_ids, null: false
      t.string :heading, null: false
      t.string :body
      t.string :one_liner
      t.string :deeplink

      t.timestamps
    end
  end
end
