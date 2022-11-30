class CreateStreamEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :stream_events do |t|
      t.integer :source, null: false, default: 0
      t.string :name, null: false
      t.string :source_path
      t.string :source_component

      t.references :subject, polymorphic: true
      t.references :user, null: true
      t.jsonb :payload, null: false, default: {}

      t.timestamps null: false
    end

    add_index :stream_events, :name
  end
end
