class AddPersonalToCollections < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :collections, :personal, :boolean, null: false, default: false
    end
  end
end
