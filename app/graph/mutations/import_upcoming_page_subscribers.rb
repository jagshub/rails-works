# frozen_string_literal: true

module Graph::Mutations
  class ImportUpcomingPageSubscribers < BaseMutation
    argument_record :upcoming_page, -> { UpcomingPage.not_trashed }, required: true, authorize: ApplicationPolicy::MAINTAIN
    argument :payload, String, required: false
    argument :upcoming_page_segment_id, ID, required: false

    returns Graph::Types::UpcomingPageType

    def perform(upcoming_page:, payload: nil, upcoming_page_segment_id: nil)
      segment = upcoming_page.segments.find(upcoming_page_segment_id) if upcoming_page_segment_id

      return error(:payload, 'Required') if payload.blank?
      return error(:payload, 'Invalid file format - only CSV files allowed') unless valid_file_format?(payload)

      import = UpcomingPageEmailImport.create!(
        upcoming_page: upcoming_page,
        segment: segment,
        payload_csv: payload,
      )

      UpcomingPages::MakerTasks.complete(upcoming_page)
      UpcomingPages::ImportWorker.perform_later(import)

      upcoming_page
    end

    private

    def valid_file_format?(payload)
      return true if payload.starts_with?('data:text/csv;base64,')

      # NOTE(rstankov): Windows marks CSV as Excel
      return true if payload.starts_with?('data:application/vnd.ms-excel;base64,')

      # ]NOTE(rstankov): Sometimes browser doesn't know this is CSV
      return true if payload.starts_with?('data:application/octet-stream;base64,')

      return false if payload =~ /^data:[^;]*;/

      true
    end
  end
end
