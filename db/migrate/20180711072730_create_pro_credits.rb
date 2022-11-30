class CreateProCredits < ActiveRecord::Migration[5.0]
  def change
    create_table :pro_credits do |t|
      t.string :stripe_order_id, null: true
      t.belongs_to :user, foreign_key: true, index: true, null: false
      t.belongs_to :post, foreign_key: true, index: true, null: true
      t.datetime :refunded_at, null: true
      t.timestamps null: false
    end
  end
end
