# frozen_string_literal: true

class Admin::Users::DisconnectSocialAccount
  attr_reader :user, :account, :attribute_name

  def initialize(user, account:)
    @user = user
    @account = account
    @attribute_name = "#{ account }_uid".to_sym
  end

  class << self
    def call(user, account:)
      new(user, account: account).call
    end
  end

  def call
    raise "unknown account type - #{ account }" unless SignIn::SOCIAL_ATTRIBUTES.include?(attribute_name)

    return "can't remove, user needs more than 1 social account" unless user.connected_social_accounts_count > 1

    user[attribute_name] = nil
    user.twitter_username = nil if attribute_name == :twitter_uid

    return "could not remove #{ account } account, talk to a developer :)" unless user.save

    user.access_tokens.where(token_type: account).destroy_all

    "#{ account } account removed!"
  end
end
