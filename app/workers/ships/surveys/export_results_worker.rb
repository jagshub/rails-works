# frozen_string_literal: true

class Ships::Surveys::ExportResultsWorker < FileExports::CsvWorker
  def mail_subject(survey:, **_options)
    "Export of #{ survey.title } results"
  end

  def mail_message(survey:, **_options)
    "Your export of #{ survey.title } results is ready."
  end

  def note(survey:, **_options)
    "Results for survey ##{ survey.id }"
  end

  def csv_contents(csv, survey:, **_options)
    questions = survey.questions.by_position.to_a

    csv << header_for(questions)

    survey.subscribers.find_each do |subscriber|
      csv << row_for(questions, subscriber: subscriber)
    end

    csv
  end

  private

  def header_for(questions)
    %i(id email name username user_id).concat(questions.map(&:title))
  end

  def row_for(questions, subscriber:)
    row = [subscriber.id, subscriber.email, subscriber.user&.name, subscriber.user&.username, subscriber.user_id]

    questions.each do |question|
      row << title_for(question, subscriber)
    end

    row
  end

  def title_for(question, subscriber)
    titles = question.answers.where(upcoming_page_subscriber_id: subscriber.id).map do |question_answer|
      if question.freeform?
        question_answer.freeform_text
      elsif question_answer.other?
        question_answer.freeform_text || 'Other'
      else
        question_answer.option&.title || ''
      end
    end

    titles.size > 1 ? titles.join(',') : titles.first
  end
end
