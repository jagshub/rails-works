# frozen_string_literal: true

class Notifications::Channels::Email::TopMakerNotification < Notifications::Channels::Email::Base
  attr_reader :post

  def initialize(notification)
    super

    @post = @notification.notifyable
  end

  def email_subject
    %(Congrats! #{ post.name } earned #{ post.votes_count } upvotes 🙌)
  end

  def from_name
    CommunityContact::PH_NAME
  end

  def from_email
    CommunityContact::PH_EMAIL
  end

  def campaign
    'top_maker_notification'
  end

  def reply_header
    { 'Reply-To' => CommunityContact::REPLY }
  end

  def template_id
    # Note (Rahul): You can edit this template (Product Hunt - Top 10) here
    #               (https://app.mailjet.com/templates/transactional) with main api key.
    '351818'
  end

  def template_variables
    { 'user_name' => notification.subscriber.name, 'product_name' => post.name, 'votes' => post.votes_count }
  end

  def unsubscribe_url
    # Note (Mike Coutermarsh): No unsub URL. This is an email "from Jake"
    ''
  end
end
