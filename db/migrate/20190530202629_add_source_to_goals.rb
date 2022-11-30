class AddSourceToGoals < ActiveRecord::Migration[5.1]
  def change
    add_column :goals, :source, :string

    add_index :goals, :source, where: 'source IS NOT NULL'
  end
end
