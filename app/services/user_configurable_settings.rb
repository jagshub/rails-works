# frozen_string_literal: true

class UserConfigurableSettings
  def reload
    @settings = nil
  end

  # rubocop: disable Style/MethodMissingSuper
  def method_missing(key)
    return trueish_value?(key) if key[-1, 1] == '?'

    get_value(key)
  end
  # rubocop:enable

  def respond_to_missing?(_method_name, _include_private = false)
    true
  end

  def [](key)
    get_value(key)
  end

  def array(key)
    get_value(key).to_s.split(/,\W?/).map(&:strip)
  end

  def usernames(value)
    array(value).map(&:downcase)
  end

  private

  # returns false if value 0 '0' nil or blank
  def trueish_value?(key)
    key = key.to_s.chomp('?')
    value = get_value(key)
    value.present? && value != 0 && value != '0' && value != 'false'
  end

  def get_value(key)
    settings[key.to_sym]
  end

  def settings
    @settings = nil if expired?
    @settings ||= fetch_settings
  end

  def expired?
    @loaded_at && @loaded_at < 1.hour.ago
  end

  def fetch_settings
    @loaded_at = Time.current

    Setting.all.each_with_object({}) do |el, result|
      result[el.name.to_sym] = parse(el.value)
    end.reverse_merge(defaults)
  end

  def parse(value)
    return parse_json(value) if value.starts_with?('{')

    value
  end

  def parse_json(value)
    Oj.load(value).with_indifferent_access || {}
  rescue Oj::ParseError
    {}
  end

  def defaults
    {
      rank_floor: '0.0019',
      rank_time_multiplier: '1.35',
      rank_time_addition: '900',
      rank_upvote_addition: '20',

      trending_searches: 'start up, ios, app, chat, game',

      ship_max_import_before_flagged: '100000',
    }
  end
end
