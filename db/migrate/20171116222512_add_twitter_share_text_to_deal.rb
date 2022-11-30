class AddTwitterShareTextToDeal < ActiveRecord::Migration[5.0]
  def change
    add_column :deals, :twitter_share_text, :text
  end
end
