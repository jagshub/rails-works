class AddTrackingSnippetToDeal < ActiveRecord::Migration[5.0]
  def change
    add_column :deals, :tracking_snippet, :text
  end
end
