# frozen_string_literal: true

module Flags
  extend self

  def create_form(user:, subject:)
    Flags::CreateForm.new user, subject
  end

  def resolve_all_for(record:, moderator:)
    record.user_flags.unresolved.update_all(
      status: 'resolved',
      moderator_id: moderator.id,
    )
  end

  def resolve_by_moderator(flag:, moderator:)
    return flag if flag.resolved?

    flag.update! status: 'resolved', moderator: moderator

    flag
  end
end
