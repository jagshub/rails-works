class AddEmploymentSeniorityToClearbitPersonProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :clearbit_person_profiles, :employment_seniority, :string, null: true
  end
end
