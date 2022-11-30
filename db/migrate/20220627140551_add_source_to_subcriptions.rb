class AddSourceToSubcriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :source, :string, null: true
  end
end
