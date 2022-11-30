class AddCustomDomainToUpcomingPages < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_pages, :custom_domain, :string
  end
end
