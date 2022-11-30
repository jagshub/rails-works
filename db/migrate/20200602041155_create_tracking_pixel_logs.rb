class CreateTrackingPixelLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :tracking_pixel_logs do |t|
      t.integer :kind, null: false
      t.string :host, null: false
      t.string :url, null: false
      t.datetime :last_seen_at, null: false
      t.references :embeddable, polymorphic: true, index: true, null: false

      t.timestamps
    end

    add_index :tracking_pixel_logs, [:kind, :host, :embeddable_type, :embeddable_id], unique: true, name: "index_kind_and_host_and_e_type_and_e_id"
  end
end
