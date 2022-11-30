# frozen_string_literal: true

module Posts::LaunchDay::Reports::Pdf
  extend self

  def generate_pdf(report)
    html = ApplicationController.render(
      template: 'insights/post_launch_report',
      layout: false,
      formats: [:html],
      locals: {
        :@data => report.data,
        :@post => report.post,
      },
    )

    Grover.new(
      html,
      landscape: false,
      display_url: display_url,
      full_page: true,
      margin: { top: '1cm', bottom: '1cm' },
    ).to_pdf
  end

  def display_url
    if Rails.env.production?
      'https://www.producthunt.com/'
    else
      'http://ph.test:5051/'
    end
  end
end
