# frozen_string_literal: true

class MakersFestival::NotifyFriendsWorker < ApplicationJob
  def perform(participant:)
    festival = participant.makers_festival_category.makers_festival_edition
    categories = festival.categories.map(&:id)
    participant_user_ids = MakersFestival::Participant.where(makers_festival_category: categories).pluck(:user_id)

    participant
      .user.friends
      .joins(:subscriber)
      .where.not(id: participant_user_ids, 'notifications_subscribers.email' => nil)
      .without_makers_fest_email_received(festival)
      .with_notification_preferences('send_friend_post_email')
      .find_each do |friend|
      ActiveRecord::Base.transaction do
        friend.received_makers_fest_email_for = festival
        friend.save!
        MakersFestivalMailer.friend_registered(festival: festival, user_to_mail: friend, friend_who_registered: participant.user).deliver_now
      end
    end
  end
end
