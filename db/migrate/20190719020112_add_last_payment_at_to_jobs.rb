class AddLastPaymentAtToJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :last_payment_at, :datetime

    reversible do |dir|
      dir.up {
        execute 'UPDATE jobs SET last_payment_at = external_created_at'
      }
    end
  end
end
