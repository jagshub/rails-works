class RemoveProCredits < ActiveRecord::Migration[5.0]
  def change
    drop_table :pro_credits
  end
end
