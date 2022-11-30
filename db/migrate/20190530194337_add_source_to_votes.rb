class AddSourceToVotes < ActiveRecord::Migration[5.1]
  def change
    add_column :votes, :source, :string

    add_index :votes, :source, where: 'source IS NOT NULL'
  end
end
