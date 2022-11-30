# frozen_string_literal: true

class Voting::Checks::Worker < ApplicationJob
  include ActiveJobHandleDeserializationError

  def perform(vote)
    Voting::Checks.run_all_checks(vote)
  end
end
