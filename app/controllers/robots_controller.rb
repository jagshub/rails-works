# frozen_string_literal: true

class RobotsController < ApplicationController
  def root
    render plain: ''
  end

  def no_robots
    render plain: "User-agent: *\nDisallow: /", content_type: 'text/plain'
  end
end
