class RemoveRoleFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :role, :string
    add_column :users, :role, :integer, default: 0
    @users = User.all
    @users.each do |u|
      old_role = u[:old_role]
      case old_role
      when "user"
        u.role = "user"
        u.save!
      when "comment_only"
        u.role = "can_only_comment"
        u.save!
      when "verified"
        u.role = "can_post"
        u.save!
      when "banner_from_vote"
        u.role = "cannot_upvote"
        u.save!
      when "admin"
        u.role = "admin"
        u.save!
      end
    end
  end
end
