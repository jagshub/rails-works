class AddEmploymentRoleToClearbitPersonProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :clearbit_person_profiles, :employment_role, :string
  end
end
