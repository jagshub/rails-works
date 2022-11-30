class AddHeaderCreditToStories < ActiveRecord::Migration[5.0]
  def change
    add_column :anthologies_stories, :header_image_credit, :string
  end
end
