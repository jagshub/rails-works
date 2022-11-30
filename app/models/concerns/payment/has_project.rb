# frozen_string_literal: true

module Payment::HasProject
  extend ActiveSupport::Concern

  included do
    validates :project, presence: true
    enum project: {
      founder_club: 1,
    }
  end

  module ClassMethods
    def from_project(project)
      raise ::Payments::Errors::InvalidProjectError unless projects.key? project

      where(project: project)
    end
  end
end
