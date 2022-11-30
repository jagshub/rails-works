class FixDeepNestedComments < ActiveRecord::Migration
  def up
    # Note Sanity checks for in case we rename models or fields in future
    return unless defined?(Comment)
    return unless Comment.new.respond_to?(:parent_comment_id) && Comment.new.respond_to?(:parent)

    Comment.where.not(parent_comment_id: nil).includes(:parent).find_each do |comment|
      next unless comment.parent.present? && comment.parent.parent.present?
      comment.update(parent_comment_id: comment.parent.parent.id)
    end
  end

  def down
    # left for explicitness
  end
end
