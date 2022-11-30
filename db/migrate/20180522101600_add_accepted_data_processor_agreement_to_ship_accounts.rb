class AddAcceptedDataProcessorAgreementToShipAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_accounts, :data_processor_agreement, :integer, default: 0, null: false
  end
end
