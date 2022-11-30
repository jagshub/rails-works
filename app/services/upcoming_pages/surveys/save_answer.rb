# frozen_string_literal: true

class UpcomingPages::Surveys::SaveAnswer
  def self.call(subscriber:, question:, inputs:)
    form = new(subscriber: subscriber, question: question)
    form.save(inputs)
  end

  attr_reader :subscriber, :question

  def initialize(subscriber:, question:)
    @subscriber = subscriber
    @question = question
  end

  def save(inputs)
    result = build_answers(inputs)

    return false if result.nil?

    answers = Array(result)

    UpcomingPageQuestionAnswer.transaction do
      clear_previous_answers
      answers.each(&:save!)
    end

    notify_about answers

    true
  end

  private

  def build_answers(inputs)
    return unless question.survey.opened?

    if question.freeform?
      build_free_form_answer(inputs)
    else
      build_answer_from_options(inputs)
    end
  end

  def build_free_form_answer(inputs)
    text = inputs[:upcoming_page_question_freeform_text]

    return if text.blank? && question.required?

    build_answer(kind: :freeform, freeform_text: text)
  end

  def build_answer_from_options(inputs)
    options = question.options.where(id: inputs[:upcoming_page_question_options_ids]).all

    return unless options_valid?(options, inputs)

    answers = options.map do |option|
      build_answer(kind: :option, upcoming_page_question_option_id: option.id)
    end

    answers << build_answer(kind: :other, freeform_text: inputs[:upcoming_page_question_freeform_text]) if inputs[:other_selected]
    answers
  end

  def options_valid?(options, inputs)
    return false if options.size != inputs[:upcoming_page_question_options_ids]&.size
    return false if question.single_select? && options.size > 1
    return true unless question.required?

    if inputs[:other_selected].present?
      inputs[:upcoming_page_question_freeform_text].present?
    else
      options.present?
    end
  end

  def build_answer(attributes)
    UpcomingPageQuestionAnswer.new(attributes.merge(
                                     upcoming_page_question_id: question.id,
                                     upcoming_page_subscriber_id: subscriber.id,
                                   ))
  end

  def clear_previous_answers
    question.answers.where(upcoming_page_subscriber_id: subscriber.id).delete_all
  end

  def notify_about(answers)
    return if answers.empty?

    Notifications.notify_about kind: :ship_survey_completion, object: answers.last if last_question?(question)
  end

  def last_question?(question)
    question.position_in_survey == question.survey.questions.pluck(Arel.sql('MAX(position_in_survey)')).first
  end
end
