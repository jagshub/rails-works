# frozen_string_literal: true

class Frontend::StatusController < ApplicationController
  def index
    render json: { app: :backend }
  end
end
