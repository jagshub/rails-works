class CreateShipPaymentReports < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_payment_reports do |t|
      t.integer :net_revenue, null: false
      t.datetime :date, null: false
      t.timestamps null: false
    end
  end
end
