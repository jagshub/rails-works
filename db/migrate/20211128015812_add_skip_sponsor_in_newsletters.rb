class AddSkipSponsorInNewsletters < ActiveRecord::Migration[6.1]
  def change
    add_column :newsletters, :skip_sponsor, :boolean, default: false
  end
end
