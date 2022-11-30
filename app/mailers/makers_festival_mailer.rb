# frozen_string_literal: true

class MakersFestivalMailer < ApplicationMailer
  def friend_registered(festival:, user_to_mail:, friend_who_registered:)
    email_campaign_name "Makers Festival #{ festival.name }", deduplicate: true

    @user = user_to_mail
    @friend = friend_who_registered
    @festival = festival

    mail(
      to: user_to_mail.email,
      subject: "#{ friend_who_registered.name.titleize } joined the Makers Festival",
    )
  end

  def request_api_key(email:)
    mail(
      to: email,
      subject: 'Update your API Key for write access to Product Hunt API 2.0',
    )
  end

  def what_are_you_building(email:)
    mail(
      to: email,
      subject: 'What are you building for Makers Festival? We would love to lend a helping hand',
    )
  end

  def submission_deadline_approaching(user:)
    @user = user

    mail(
      to: user.email,
      subject: "It's almost time for the Makers Festival submissions",
    )
  end

  def launch_on_ph(email:)
    mail(
      to: email,
      subject: 'Launch your Makers Festival submission on Product Hunt',
    )
  end
end
