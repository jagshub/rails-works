class AddProviderToUsersRegistrationReasons < ActiveRecord::Migration[5.2]
  def change
    add_column :users_registration_reasons, :provider, :string, null: true
  end
end
