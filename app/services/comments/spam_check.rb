# frozen_string_literal: true

class Comments::SpamCheck < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(comment:, request_info:)
    SpamChecks.check_comment comment, request_info
  end
end
