class AddSlugToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :slug, :string, null: true
  end
end
