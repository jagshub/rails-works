class RemoveShipMessageTemplate < ActiveRecord::Migration[5.0]
  def change
    drop_table :ship_message_templates
  end
end
