class CreateSipPollOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :sip_poll_options do |t|
      t.references :sip_poll, foreign_key: true, null: false
      t.integer :position_in_poll, default: 0, null: false
      t.text :option, null: false

      t.timestamps
    end
  end
end
