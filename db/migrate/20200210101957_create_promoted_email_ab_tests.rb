class CreatePromotedEmailAbTests < ActiveRecord::Migration[5.1]
  def change
    create_table :promoted_email_ab_tests do |t|
      t.boolean :test_running, null: false, default: false

      t.timestamps
    end
  end
end
