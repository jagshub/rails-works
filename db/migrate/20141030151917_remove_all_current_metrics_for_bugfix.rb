class RemoveAllCurrentMetricsForBugfix < ActiveRecord::Migration
  def up
    # Note(andreasklinger): We are removing all current metrics
    #   The next rake task will automatically regenerate them
    execute "TRUNCATE metrics"
  end

  def down
    # noop
  end
end
