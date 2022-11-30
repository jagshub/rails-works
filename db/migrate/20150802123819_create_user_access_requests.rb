class CreateUserAccessRequests < ActiveRecord::Migration
  def change
    create_table :user_access_requests do |t|
      t.integer :status, default: 0, null: false
      t.references :user, index: true, null: false, unique: true
      t.references :handled_by, index: true

      t.timestamps null: false
    end
  end
end
