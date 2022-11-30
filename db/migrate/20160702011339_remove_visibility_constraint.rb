class RemoveVisibilityConstraint < ActiveRecord::Migration
  def change
    # Note(andreasklinger): By accident the previous migration already had the
    #   removal of this column. Neither CI on staging nor production crashed
    #   so we didnt notice.
    #   Commenting it out post-mortem to avoid further crashes of db:migrate
    #   or db:migrate:reset
    # change_column_null :categories, :visibility, true
  end
end
