class AddSponsorTitleToNewsletters < ActiveRecord::Migration[6.1]
  def change
    add_column :newsletters, :sponsor_title, :string, default: 'Sponsored By'
  end
end
