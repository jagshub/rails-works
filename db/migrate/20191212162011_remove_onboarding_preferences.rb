class RemoveOnboardingPreferences < ActiveRecord::Migration[5.1]
  def change
    safety_assured { remove_column :users, :onboarding_preferences, :jsonb }
  end
end
