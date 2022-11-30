class AddExclusiveTextAndExclusiveMakerIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :exclusive_text, :string
    add_column :posts, :exclusive_maker_id, :integer
  end
end
