# frozen_string_literal: true

module Newsletter::Experiment::Finish
  extend self

  def call(experiment)
    subject_winner = experiment.variants.find_by variant_winner: 'subject'

    return unless subject_winner

    experiment.newsletter.update! subject: subject_winner.subject

    true
  end
end
