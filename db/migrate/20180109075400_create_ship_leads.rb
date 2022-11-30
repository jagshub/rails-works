class CreateShipLeads < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_leads do |t|
      t.string :email, null: false
      t.string :name, null: true

      t.integer :status, null: false, default: 0

      t.string :project_name, null: true
      t.string :project_tagline, null: true

      t.integer :project_phase, null: false, default: 0
      t.integer :launch_period, null: false, default: 0

      t.references :user, index: true, null: true
      t.references :ship_instant_access_page, null: true

      t.timestamps null: false
    end
  end
end
