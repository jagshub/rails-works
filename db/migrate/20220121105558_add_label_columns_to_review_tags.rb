class AddLabelColumnsToReviewTags < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      rename_column :review_tags, :body, :property
    end

    add_column :review_tags, :positive_label, :string
    add_column :review_tags, :negative_label, :string
  end
end
