# frozen_string_literal: true

class Ships::Slack::DeclinedDpa < Ships::Slack::Notification
  attr_reader :ship_account

  class << self
    def call(ship_account)
      new(ship_account).deliver
    end
  end

  def initialize(ship_account)
    @ship_account = ship_account
  end

  private

  def channel
    'ship_community_activity'
  end

  def author
    @author ||= ship_account.user
  end

  def title
    'User declined DPA'
  end

  def title_link
    "https://www.producthunt.com/admin/ship_accounts/#{ ship_account.id }"
  end

  def fields
    [
      { title: 'Email', value: ship_account.user&.email, short: true },
      { title: 'User ID', value: ship_account.user&.id, short: true },
      { title: 'Username', value: ship_account.user&.username, short: true },
    ]
  end

  def icon_emoji
    ':scream_cat:'
  end

  def color
    '#980000'
  end
end
