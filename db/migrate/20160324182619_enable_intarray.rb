class EnableIntarray < ActiveRecord::Migration
  def change
    enable_extension :intarray
  end
end
