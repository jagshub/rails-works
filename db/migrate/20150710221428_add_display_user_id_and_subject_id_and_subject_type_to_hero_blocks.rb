class AddDisplayUserIdAndSubjectIdAndSubjectTypeToHeroBlocks < ActiveRecord::Migration
  def change
    add_column :hero_blocks, :display_user_id, :integer
    add_column :hero_blocks, :subject_id, :integer
    add_column :hero_blocks, :subject_type, :string
  end
end
