class AddNullConstraintToInvitesLeft < ActiveRecord::Migration
  class User < ApplicationRecord; end

  def change
    User.where(invites_left: nil).update_all(invites_left: 0)
    change_column_null :users, :invites_left, false
  end
end
