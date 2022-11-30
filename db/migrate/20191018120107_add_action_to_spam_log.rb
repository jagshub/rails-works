class AddActionToSpamLog < ActiveRecord::Migration[5.1]
  def change
    add_column :spam_logs, :action, :string
  end
end
