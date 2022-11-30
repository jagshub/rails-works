class AddUserExperimentTags < ActiveRecord::Migration
  def change
    add_column :users, :experiment_tags, :jsonb, null: false, default: '{}'
    add_index :users, :experiment_tags, using: :gin
  end
end
