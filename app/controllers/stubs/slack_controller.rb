# frozen_string_literal: true

class Stubs::SlackController < ApplicationController
  def self.response_params
    {}
  end

  def index
    redirect_to slack_path(self.class.response_params)
  end
end
