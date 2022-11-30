class CreateShipAwsApplications < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_aws_applications do |t|
      t.string :startup_name, null: false
      t.string :startup_email, null: false
      t.references :ship_account, null: false, foreign_key: true
      t.timestamps null: false
    end
  end
end
