class CreateCheckoutPageLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :checkout_page_logs do |t|
      t.references :checkout_page, null: false, index: true
      t.references :user, null: false, index: true
      t.string :billing_email, null: false
      t.timestamps null: false
    end
  end
end
