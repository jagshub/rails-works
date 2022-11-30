class CreateShipCancellationReasons < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_cancellation_reasons do |t|
      t.text :reason, null: false
      t.integer :billing_plan, null: false
      t.references :user, null: false
      t.timestamps null: false
    end
  end
end
