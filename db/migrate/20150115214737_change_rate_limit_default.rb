class ChangeRateLimitDefault < ActiveRecord::Migration
  def change
    change_column_default(:oauth_applications, :max_requests_per_hour, 3600)
  end
end
