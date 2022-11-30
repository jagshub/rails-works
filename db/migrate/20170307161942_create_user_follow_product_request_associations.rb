class CreateUserFollowProductRequestAssociations < ActiveRecord::Migration
  def change
    create_table :user_follow_product_request_associations do |t|
      t.references :user, index: { name: 'index_user_follow_product_requests_on_user' }, foreign_key: true, null: false
      t.references :product_request, index: { name: 'index_user_follow_product_requests_on_product_request' }, foreign_key: true, null: false

      t.timestamps null: false
    end

    add_index :user_follow_product_request_associations, [:user_id, :product_request_id], unique: true, name: 'index_user_follow_product_requests_on_user_and_product_request'
  end
end
