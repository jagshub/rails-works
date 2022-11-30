class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.uuid :uuid, null: false, default: 'gen_random_uuid()'
      t.references :user, index: true, foreign_key: true
      t.references :plan, index: true, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.integer :status
      t.string :payment_method
      t.string :remote_id

      t.timestamps null: false
    end

    add_index :subscriptions, :uuid, unique: true
  end
end
