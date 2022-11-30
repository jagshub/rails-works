# frozen_string_literal: true

class TwitterApi::SyncVerifiedUsers
  VERIFIED_ACCOUNT = 'verified'

  class << self
    # NOTE(LukasFittl): This is intended to be a sync commany you manually
    # run from the console once - if re-running you first need to truncate the table
    def call
      client = TwitterApi::Client.new
      uids = client.friend_uids_for_username(VERIFIED_ACCOUNT)
      uids_and_usernames = client.uids_to_uid_and_username(uids)

      TwitterVerifiedUser.import %i(twitter_uid twitter_username), uids_and_usernames
    end
  end
end
