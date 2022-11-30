# frozen_string_literal: true

class Graph::Resolvers::ViewerNotice < Graph::Resolvers::Base
  NOTICES = [
    {
      type: 'signup_onboarding_pending',
      show: -> { !UserOnboarding.completed? current_user },
    },
    {
      type: 'email_verification_pending',
      show: -> { !current_user.verified? },
    },
    {
      type: 'account_suspended',
      show: -> { current_user.bad_actor? },
    },
  ].freeze

  class NoticeTypeEnum < Graph::Types::BaseEnum
    NOTICES.each do |notice|
      value notice[:type]
    end
  end

  type NoticeTypeEnum, null: true

  def resolve
    return if current_user.nil?

    NOTICES.find do |notice|
      return notice[:type] if instance_exec(&notice[:show])

      nil
    end
  end
end
