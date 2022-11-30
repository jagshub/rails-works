class CreateOnboardingReasons < ActiveRecord::Migration[5.1]
  def change
    create_table :onboarding_reasons do |t|
      t.string :reason, null: false
      t.references :user, foreign_key: true, index: true, null: false    

      t.timestamps
    end

    add_index :onboarding_reasons, [:user_id, :reason], unique: true
  end
end
