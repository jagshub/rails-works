# frozen_string_literal: true

class API::Widgets::Upcoming::V1::PixelController < ActionController::API
  after_action :track, only: :index

  def index
    # NOTE(naman): decoded base64 for transparent pixel
    response.headers['Content-Type'] = 'image/png'
    send_data(
      "\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\b\x04\x00\x00\x00\xB5\x1C\f\x02\x00\x00\x00\vIDATx\xDAcd`\x00\x00\x00\x06\x00\x020\x81\xD0/\x00\x00\x00\x00IEND\xAEB`\x82",
      type: 'image/png',
      disposition: 'inline',
    )
  end

  private

  def track
    upcoming_page = UpcomingPage.find params[:id]

    TrackingPixel.track(upcoming_page, :upcoming_widget, request.referer) do
      UpcomingPages::MakerTasks::EmbedUpcomingWidget.complete upcoming_page
    end
  end
end
