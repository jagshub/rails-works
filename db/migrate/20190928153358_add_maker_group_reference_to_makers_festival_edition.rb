class AddMakerGroupReferenceToMakersFestivalEdition < ActiveRecord::Migration[5.1]
  def change
    safety_assured { add_reference :makers_festival_editions, :maker_group, foreign_key: true }
  end
end
