class AllowRegistrationReasonComponentToBeNil < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users_registration_reasons, :source_component, true
  end
end
