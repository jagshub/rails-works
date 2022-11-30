class AddDefaultToJobPreference < ActiveRecord::Migration[5.0]
  def up
    change_column :users, :job_preference, :jsonb, null: false, default: {}
  end

  def down
    change_column :users, :job_preference, :jsonb
  end
end
