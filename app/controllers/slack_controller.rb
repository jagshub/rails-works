# frozen_string_literal: true

class SlackController < ApplicationController
  before_action :require_user_for_cancan_auth!

  def show
    if SlackBot.activate current_user, params[:code]
      SlackBot.greet current_user

      redirect_to landing_slack_success_path
    else
      redirect_to landing_slack_failure_path
    end
  end
end
