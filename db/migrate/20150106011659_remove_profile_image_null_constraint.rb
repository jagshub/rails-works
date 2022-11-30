class RemoveProfileImageNullConstraint < ActiveRecord::Migration
  def change
    change_column_null(:profile_images, :file, true)
  end
end
