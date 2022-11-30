class AddSubjectToMakerActivity < ActiveRecord::Migration[5.1]
  def change
    add_reference :maker_activities, :subject, null: true, polymorphic: true
  end
end
