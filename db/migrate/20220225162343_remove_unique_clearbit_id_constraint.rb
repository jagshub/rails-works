class RemoveUniqueClearbitIdConstraint < ActiveRecord::Migration[6.1]
  def up
    remove_index :clearbit_person_profiles, :clearbit_id
  end

  def down
    add_index :clearbit_person_profiles, :clearbit_id, unique: true
  end
end
