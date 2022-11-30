class ChangeTaglineToTextForMakersFestivalCategory < ActiveRecord::Migration[5.1]
  def up
    change_column :makers_festival_categories, :tagline, :text
  end

  def down
    change_column :makers_festival_categories, :tagline, :string
  end
end
