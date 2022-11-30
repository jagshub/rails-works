class AddUniqueIndexOnBudgetPlacements < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :ads_placements,
              %i(budget_id kind bundle),
              unique: true,
              algorithm: :concurrently
  end
end
