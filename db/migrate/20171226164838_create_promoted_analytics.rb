class CreatePromotedAnalytics < ActiveRecord::Migration[5.0]
  def change
    create_table :promoted_analytics do |t|
      t.references :user, foreign_key: true
      t.references :promoted_product, foreign_key: true
      t.string :ip_address
      t.string :track_code
      t.string :source
      t.string :user_action

      t.timestamps
    end
  end
end
