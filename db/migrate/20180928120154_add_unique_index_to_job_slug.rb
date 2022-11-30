class AddUniqueIndexToJobSlug < ActiveRecord::Migration[5.0]
  def change
    execute 'UPDATE jobs SET slug = null'
    add_index :jobs, :slug, unique: true
  end
end
