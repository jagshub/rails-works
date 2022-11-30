class MakeSubjectOptionalForReview < ActiveRecord::Migration[6.1]
  def change
    change_column_null :reviews, :subject_type, true
    change_column_null :reviews, :subject_id, true
  end
end
