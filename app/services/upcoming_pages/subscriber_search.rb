# frozen_string_literal: true

class UpcomingPages::SubscriberSearch
  def self.results(upcoming_page, filters)
    new(upcoming_page).apply(upcoming_page.confirmed_subscribers, filters)
  end

  def initialize(upcoming_page)
    @upcoming_page = upcoming_page
  end

  def apply(scope, filters)
    (filters || []).uniq { |filter| "#{ filter['type'] }:#{ filter['value'] }" }.reduce(scope) { |acc, elem| apply_filter(elem, acc) || acc }
  end

  private

  def apply_filter(filter, scope)
    value = filter['value']

    return if value.blank?

    case filter['type']
    when 'segment' then apply_filter_by_segment(scope, value)
    when 'email' then apply_filter_by_email(scope, value)
    when 'name' then apply_filter_by_name(scope, value)
    when 'option' then apply_filter_by_option(scope, value)
    when 'subscriber_id' then apply_filter_by_subscriber_id(scope, value)
    end
  end

  def apply_filter_by_segment(scope, value)
    case value
    when 'users' then scope.user
    when 'guests' then scope.guest
    when 'makers' then scope.maker
    when 'imported' then scope.imported
    when 'not_imported' then scope.not_imported
    when 'not_messaged' then apply_filter_by_not_messaged(scope, value)
    when /\d+/ then scope.by_segment_id(value)
    end
  end

  def apply_filter_by_email(scope, value)
    scope.for_email(value)
  end

  def apply_filter_by_name(scope, value)
    scope.joins(:contact).joins('LEFT JOIN users ON users.id = ship_contacts.user_id').where('users.name ILIKE :match OR users.username LIKE :match', match: LikeMatch.by_words(value))
  end

  def apply_filter_by_option(scope, value)
    scope.where('upcoming_page_subscribers.id IN (SELECT upcoming_page_subscriber_id FROM upcoming_page_question_answers WHERE upcoming_page_question_option_id = ?)', value)
  end

  def apply_filter_by_subscriber_id(scope, value)
    scope.where('upcoming_page_subscribers.id' => value)
  end

  def apply_filter_by_not_messaged(scope, _value)
    scope
      .joins('left join upcoming_page_message_deliveries on upcoming_page_message_deliveries.upcoming_page_subscriber_id = upcoming_page_subscribers.id')
      .where('upcoming_page_message_deliveries.id' => nil)
  end
end
