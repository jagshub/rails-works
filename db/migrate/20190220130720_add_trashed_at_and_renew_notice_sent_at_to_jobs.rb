class AddTrashedAtAndRenewNoticeSentAtToJobs < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_column :jobs, :trashed_at, :datetime
    add_column :jobs, :renew_notice_sent_at, :datetime

    add_index :jobs, :trashed_at, where: 'trashed_at IS NULL', algorithm: :concurrently
  end
end
