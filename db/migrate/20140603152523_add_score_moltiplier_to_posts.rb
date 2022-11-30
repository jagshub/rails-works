class AddScoreMoltiplierToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :score_multiplier, :float, :precision => 3, :scale => 2, :default => 1.00
  end
end
