class RemoveSubjectFromReview < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_reference :reviews, :subject, index: true, polymorphic: true }
  end
end
