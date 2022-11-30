class CreateAdTables < ActiveRecord::Migration[5.1]
  def change
    create_table :ads_campaigns do |t|
      t.references :post, null: true, foreign_key: true

      t.string :name, null: false
      t.string :tagline, null: false
      t.uuid :thumbnail_uuid, null: false
      t.string :url, null: false
      t.json :url_params, null: false, default: {}
      t.integer :budgets_count, null: false, default: 0
      t.integer :active_budgets_count, null: false, default: 0
      t.string :cta_text
      t.string :deal_text

      t.timestamps
    end

    create_table :ads_budgets do |t|
      t.references :campaign,
                   foreign_key: { to_table: :ads_campaigns },
                   null: false

      t.string :kind, null: false
      t.integer :placements_count, null: false, default: 0
      t.integer :active_placements_count, null: false, default: 0
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end

    add_index :ads_budgets, :start_time, where: 'start_time IS NOT NULL'
    add_index :ads_budgets, :end_time, where: 'end_time IS NOT NULL'

    create_table :ads_placements do |t|
      t.references :budget,
                   foreign_key: { to_table: :ads_budgets },
                   null: false

      t.string :kind, null: false, index: true
      t.string :bundle, null: false, index: true
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
