class AddLinkSectionToNewsletterEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :newsletter_events, :link_section, :string
  end
end
