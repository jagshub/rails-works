# frozen_string_literal: true

module API::V1::UserDataPresenter
  class << self
    def call(user, string_ids: false)
      return TrashedUser.new(user, string_ids) if user.trashed?

      NormalUser.new(user, string_ids)
    end
  end

  class NormalUser
    def initialize(user, string_ids)
      @user = user
      @string_ids = string_ids
    end

    attr_reader :user, :string_ids
    delegate :created_at, :name, :username, :email, :headline, :twitter_username, :website_url, :maker?, :avatar, to: :user

    def id
      string_ids ? user.id.to_s : user.id # NOTE(andreasklinger): IDs are ID/String in the frontend
    end

    def profile_url
      Routes.profile_url(username)
    end

    def trashed
      false
    end
  end

  class TrashedUser
    def initialize(user, string_ids)
      @user = user
      @string_ids = string_ids
    end

    attr_reader :user, :string_ids
    delegate :created_at, :avatar, to: :user

    def id
      string_ids ? user.id.to_s : user.id # NOTE(andreasklinger): IDs are ID/String in the frontend
    end

    def name
      '[deleted user]'
    end

    def username
      'deleted_user'
    end

    def email
      nil
    end

    def headline
      nil
    end

    def twitter_username
      nil
    end

    def website_url
      nil
    end

    def maker?
      false
    end

    def profile_url
      Routes.root_url
    end

    def trashed
      true
    end
  end
end
