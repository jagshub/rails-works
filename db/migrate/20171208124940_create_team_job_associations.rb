class CreateTeamJobAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :team_job_associations do |t|
      t.references :team, null: false
      t.references :job, null: false
      t.timestamps null: false
    end

    add_foreign_key :team_job_associations, :teams, on_delete: :cascade
    add_foreign_key :team_job_associations, :jobs, on_delete: :cascade

    add_index :team_job_associations, [:team_id, :job_id], unique: true, name: 'index_job_team_associations_team_job'
  end
end
