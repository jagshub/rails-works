class TruncateMetricsStats < ActiveRecord::Migration
  def change
    # Note(andreasklinger): We are removing all current metrics
    #   The next rake task will automatically regenerate them
    execute "TRUNCATE metrics"
  end
end
