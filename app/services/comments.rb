# frozen_string_literal: true

module Comments
  extend self

  def destroy(comment:, user:)
    Comments::Destroy.call(comment: comment, user: user)
  end
end
