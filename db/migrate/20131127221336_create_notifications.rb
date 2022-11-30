class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.string :body
      t.references :post, index: true

      t.timestamps
    end
  end
end
