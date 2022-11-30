class AddJobPreferenceToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :job_preference, :jsonb
  end
end
