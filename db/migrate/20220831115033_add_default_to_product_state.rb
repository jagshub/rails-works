class AddDefaultToProductState < ActiveRecord::Migration[6.1]
  def change
    change_column_default :products, :state, from: nil, to: 'live'
    safety_assured { change_column_null :products, :state, false, 'live' }
  end
end
