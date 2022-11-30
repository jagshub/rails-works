class AddUserToSuperPeers < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_reference :super_peers, :user, foreign_key: { on_delete: :cascade }
    end
  end
end
