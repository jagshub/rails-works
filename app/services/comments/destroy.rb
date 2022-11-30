# frozen_string_literal: true

module Comments::Destroy
  extend self

  def call(comment:, user:)
    ApplicationPolicy.authorize! user, :destroy, comment

    comment.destroy!
    comment
  end
end
