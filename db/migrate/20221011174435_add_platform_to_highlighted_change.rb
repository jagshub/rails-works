# frozen_string_literal: true

class AddPlatformToHighlightedChange < ActiveRecord::Migration[6.1]
  def change
    add_column :highlighted_changes, :platform, :string, null: false, default: 'desktop'
  end
end
