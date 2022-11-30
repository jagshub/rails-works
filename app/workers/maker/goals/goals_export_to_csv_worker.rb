# frozen_string_literal: true

class Maker::Goals::GoalsExportToCsvWorker < FileExports::CsvWorker
  HEADERS = %i(goal completed due_date votes comment_count created_at last_updated).freeze

  def csv_contents(csv, user:, **_options)
    csv << HEADERS

    user.goals.find_each do |goal|
      row = [
        goal.title_text,
        goal.completed_at,
        goal.due_at,
        goal.votes_count,
        goal.comments_count,
        goal.created_at,
        goal.updated_at,
      ]

      csv << row
    end

    csv
  end

  def mail_subject(_options)
    'Export of your goals'
  end

  def mail_message(_options)
    'Your export of your goals is ready.'
  end

  def note(user:, **_options)
    "Goals for #{ user.name }"
  end
end
