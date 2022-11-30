# frozen_string_literal: true

module Stream
  class Events::UserFriendAssociationCreated < Events::Base
    event_name 'user-followed'
    allowed_subjects [UserFriendAssociation]

    should_fanout do |event|
      event.user.present? && Spam::User.credible_role?(event.user)
    end

    fanout_workers { |_event| [Stream::Activities::UserFollowed] }
  end
end
