class AddBannerMobileOnUpcomingEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :upcoming_events, :banner_mobile_uuid, :string, null: true
  end
end
