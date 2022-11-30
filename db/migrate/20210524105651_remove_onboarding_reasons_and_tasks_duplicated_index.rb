class RemoveOnboardingReasonsAndTasksDuplicatedIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :onboarding_reasons, name: 'index_onboarding_reasons_on_user_id', column: :user_id
    remove_index :onboarding_tasks, name: 'index_onboarding_tasks_on_user_id', column: :user_id
  end
end
