class CreatePaymentCardUpdateLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :payment_card_update_logs do |t|
      t.string :stripe_token_id, null: false
      t.string :stripe_customer_id, null: false
      t.string :project, null: false
      t.boolean :success, null: false, default: true
      t.references :user, index: true, foreign_key: true, null: false
      t.timestamps
    end
  end
end
