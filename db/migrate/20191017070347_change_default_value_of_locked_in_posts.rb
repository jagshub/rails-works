class ChangeDefaultValueOfLockedInPosts < ActiveRecord::Migration[5.1]
  def up
    safety_assured do
      change_column :posts, :locked, :boolean, default: false, null: false
    end
  end

  def down
    safety_assured do
      change_column :posts, :locked, :boolean, null: true
    end
  end
end
