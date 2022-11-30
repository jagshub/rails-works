# frozen_string_literal: true

class NoopController < ApplicationController
  def noop
    raise 'route must be handled by the frontend app'
  end

  def root
    render plain: ''
  end
end
