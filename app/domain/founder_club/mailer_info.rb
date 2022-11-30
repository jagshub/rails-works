# frozen_string_literal: true

module FounderClub::MailerInfo
  extend self

  def subscription_created(_subscription)
    { subject: 'Welcome to Founder Club by Product Hunt 🎉' }
  end
end
