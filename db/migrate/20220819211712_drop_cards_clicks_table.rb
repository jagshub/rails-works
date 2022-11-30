class DropCardsClicksTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :cards_clicks
  end

  def down
    raise 'Irreversible migration'
  end
end
