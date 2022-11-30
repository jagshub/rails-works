class AddGuaranteeToDeals < ActiveRecord::Migration[5.0]
  def change
    add_column :deals, :guarantee, :boolean, null: false, default: false
  end
end
