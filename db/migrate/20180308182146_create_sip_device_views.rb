class CreateSipDeviceViews < ActiveRecord::Migration[5.0]
  def change
    create_table :sip_device_views do |t|
      t.integer :viewed_slide_count
      t.integer :viewed_slide_percentage
      t.references :sip, foreign_key: true
      t.references :sip_slide, foreign_key: true
      t.references :sip_device, index: true, type: :uuid

      t.timestamps
    end
  end
end
