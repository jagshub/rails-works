class AddStateAndPromoToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :meetup_events, :state, :string
    add_column :meetup_events, :promotional_text, :string
  end
end
