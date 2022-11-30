class GenerateFriendlyIdsForPreviousProducts < ActiveRecord::Migration
  def change
    # go through previously stored products and resave to generate slugs for them
    Post.find_each(&:save)
  end
end
