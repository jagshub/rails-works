class CreateShipAccountMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_account_member_associations do |t|
      t.references :ship_account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps null: false
    end

    add_index :ship_account_member_associations, %i(ship_account_id user_id), unique: true, name: 'ship_account_member_associations_user_id_and_account_id'
  end
end
