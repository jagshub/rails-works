# frozen_string_literal: true

class Payments::EventHandler < ApplicationJob
  class << self
    def project(project)
      @project = project.to_s
    end
  end

  def perform(subscription)
    project = self.class.instance_variable_get('@project')

    raise 'Set project for this handler' unless project

    handle subscription if subscription.project == project
  end

  def handle(_subscription)
    raise NotImplementedError
  end
end
