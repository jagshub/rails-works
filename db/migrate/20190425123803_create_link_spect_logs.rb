class CreateLinkSpectLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :link_spect_logs do |t|
      t.string :external_link, null: false, index: true
      t.boolean :blocked, null: false, default: false
      t.integer :source, null: false, default: 0
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :link_spect_logs, %i(external_link expires_at)
  end
end
