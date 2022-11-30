class ChangeNewsletterSectionsToPureJson < ActiveRecord::Migration
  def change
    remove_column :newsletters, :sections, :jsonb, array: true
    add_column :newsletters, :sections, :jsonb, default: [], null: false
  end
end
