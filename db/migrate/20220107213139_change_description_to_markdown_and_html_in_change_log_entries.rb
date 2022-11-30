class ChangeDescriptionToMarkdownAndHtmlInChangeLogEntries < ActiveRecord::Migration[6.1]
  def change
    # NOTE(DZ): At time of running, table only has a couple entries and is
    # rarely visited. This should be safe
    safety_assured {
      rename_column :change_log_entries, :description, :description_md
    }
    change_column :change_log_entries, :description_md, :text
    add_column :change_log_entries, :description_html, :text
  end
end
