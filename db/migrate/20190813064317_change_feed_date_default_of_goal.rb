class ChangeFeedDateDefaultOfGoal < ActiveRecord::Migration[5.1]
  def change
    change_column_default :goals, :feed_date, from: -> { 'CURRENT_TIMESTAMP' }, to: nil
  end
end
