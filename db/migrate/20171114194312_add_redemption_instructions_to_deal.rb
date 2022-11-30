class AddRedemptionInstructionsToDeal < ActiveRecord::Migration[5.0]
  def change
    add_column :deals, :redemption_instructions, :jsonb, null: false, default: {}
  end
end
