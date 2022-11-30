# frozen_string_literal: true

class UpcomingPages::MakerTasks::BaseTask
  attr_reader :upcoming_page

  class << self
    def kind
      name.split('::').last
    end

    def create(upcoming_page)
      upcoming_page.maker_tasks.find_or_create_by(kind: kind)
    end

    def complete(upcoming_page)
      new(upcoming_page).complete
    end
  end

  def initialize(upcoming_page, maker_task = nil)
    @upcoming_page = upcoming_page
    @maker_task = maker_task if maker_task.present?
  end

  def complete
    return if maker_task.blank?
    return if maker_task.completed_at.present?
    return unless completed?

    maker_task.complete
  end

  def maker_task
    return @maker_task if instance_variable_defined? '@maker_task'

    @maker_task ||= upcoming_page.maker_tasks.find_by(kind: self.class.kind)
  end
end
