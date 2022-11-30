# frozen_string_literal: true

class Admin::Topics::RenameSuggestion
  include MiniForm::Model

  model :suggestion
  delegate :persisted?, :to_param, to: :suggestion

  attributes :name

  validates :name, presence: true

  def initialize(suggestion)
    @suggestion = suggestion
  end

  def perform
    suggestion.similar_suggestions.update_all name: name
  end
end
