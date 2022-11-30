class ChangeOnboardingNameType < ActiveRecord::Migration[5.0]
  def change
    change_column :onboardings, :name, 'integer USING 0', null: false
  end
end
