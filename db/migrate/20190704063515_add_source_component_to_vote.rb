class AddSourceComponentToVote < ActiveRecord::Migration[5.1]
  def change
    add_column :votes, :source_component, :string, null: true
  end
end
