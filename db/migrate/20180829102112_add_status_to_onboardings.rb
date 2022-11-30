class AddStatusToOnboardings < ActiveRecord::Migration[5.0]
  def up
    add_column :onboardings, :status, :integer
    add_column :onboardings, :step, :integer

    query = <<-SQL
      update onboardings set status=2
    SQL

    execute query

    change_column :onboardings, :status, :integer, default: 0, null: false
    add_index :onboardings, :status
  end

  def down
    remove_column :onboardings, :status
    remove_column :onboardings, :step
  end
end
