class RemoveCustomDomainShareButtonsGaTrackingIdFromUpcomingPages < ActiveRecord::Migration[5.0]
  def change
    remove_column :upcoming_pages, :custom_domain
    remove_column :upcoming_pages, :share_buttons
    remove_column :upcoming_pages, :ga_tracking_id
  end
end
