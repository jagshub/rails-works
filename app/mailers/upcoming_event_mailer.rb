# frozen_string_literal: true

class UpcomingEventMailer < ApplicationMailer
  def launch_schedule_confirmed(upcoming_event)
    @tracking_params = Metrics.url_tracking_params(medium: :email, object: 'launch_schedule_confirmed')
    @user = upcoming_event.user
    @subscriber = @user.subscriber
    @post = upcoming_event.post

    mail(
      to: @user.email,
      subject: 'Your upcoming launch is visible on the upcoming list',
    )
  end
end
