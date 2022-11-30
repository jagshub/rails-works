# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :require_user_for_cancan_auth!

  def index
    redirect_to profile_path(current_user.username)
  end

  def collections
    redirect_to profile_collections_path(current_user.username)
  end
end
