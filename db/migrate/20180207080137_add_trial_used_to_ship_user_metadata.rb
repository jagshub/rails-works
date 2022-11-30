class AddTrialUsedToShipUserMetadata < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_user_metadata, :trial_used, :boolean, null: false, default: false
  end
end
