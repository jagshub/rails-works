class AddTargetToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :target_type, :string
    add_column :activities, :target_id, :integer
  end
end
