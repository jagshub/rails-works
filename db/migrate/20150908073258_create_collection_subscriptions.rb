class CreateCollectionSubscriptions < ActiveRecord::Migration
  def change
    create_table :collection_subscriptions do |t|
      t.references :user
      t.references :collection, null: false
      t.string :email
      t.integer :state, null: false, default: 0

      t.timestamps null: false
    end

    add_index :collection_subscriptions, %i(user_id collection_id), unique: true
  end
end
