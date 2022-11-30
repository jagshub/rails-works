class AddOnboardingPreferencesToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :onboarding_preferences, :jsonb
  end
end
