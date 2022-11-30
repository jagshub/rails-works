class RemoveTitleFromNewsletter < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :newsletters, :title }
  end
end
