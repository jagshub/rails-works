# frozen_string_literal: true

class API::V1::SuggestionsController < API::V1::BaseController
  # NOTE(andreasklinger): This is left for older legacy iphone apps
  #   In those apps normal `user` roles would still hit the submission endpoint.
  #   As we can't do anything with those we essentially drop them here.
  #   This should no longer be needed when the new app versions are distributed.
  #   Revise in 2015-05-01
  def create
    head :created
  end
end
