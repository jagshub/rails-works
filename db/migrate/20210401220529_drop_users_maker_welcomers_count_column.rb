class DropUsersMakerWelcomersCountColumn < ActiveRecord::Migration[5.1]
  def change
    safety_assured { remove_column :users, :maker_welcomers_count, :integer }
  end
end
