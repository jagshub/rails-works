class CreateSipPolls < ActiveRecord::Migration[5.0]
  def change
    create_table :sip_polls do |t|
      t.text :question, null: false

      t.timestamps
    end
  end
end
