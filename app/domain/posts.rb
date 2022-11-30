# frozen_string_literal: true

module Posts
  extend self

  def generate_launch_report(post)
    Posts::LaunchReport.new(post)
  end
end
