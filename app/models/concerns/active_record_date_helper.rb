# frozen_string_literal: true

module ActiveRecordDateHelper
  # Note(AR): There should never be any reason to make an exact time comparison with `eq`
  DATE_EQUALITIES = %i(eq gt gteq lt lteq).freeze
  TIME_EQUALITIES = %i(gt gteq lt lteq).freeze

  module_eval do
    TIME_EQUALITIES.each do |equality|
      define_method("where_time_#{ equality }") do |field, value|
        field_type = columns_hash[field.to_s]&.type
        raise ArgumentError, "field #{ field } is not datetime (#{ field_type })" unless field_type == :datetime
        raise ArgumentError, "value #{ value } is not time-like, did you mean `where_date_#{ equality }`?" unless value.acts_like?(:time)

        where(arel_table[field].send(equality, value))
      end
    end

    DATE_EQUALITIES.each do |equality|
      define_method("where_date_#{ equality }") do |field, value|
        field_type = columns_hash[field.to_s]&.type
        raise ArgumentError, "field #{ field } is not datetime (#{ field_type })" unless field_type == :datetime
        raise ArgumentError, "value #{ value } is not date-like, did you mean `where_time_#{ equality }`?" unless value.acts_like?(:date)

        arel_statement =
          case equality
          when :eq
            # NOTE(emilov): i.e. where a >= beginning_of_day and a <=...
            arel_table[field].gteq(value.beginning_of_day).and(arel_table[field].lteq(value.end_of_day))
          when :gt
            arel_table[field].gt(value.end_of_day)
          when :gteq
            arel_table[field].gteq(value.beginning_of_day)
          when :lt
            arel_table[field].lt(value.beginning_of_day)
          when :lteq
            arel_table[field].lteq(value.end_of_day)
          end
        where(arel_statement)
      end
    end
  end

  def where_date_between(field, start_date, end_date)
    field_type = columns_hash[field.to_s]&.type
    raise ArgumentError, "field #{ field } is not datetime (#{ field_type })" unless field_type == :datetime

    start_datetime = start_date.acts_like?(:date) ? start_date.beginning_of_day : start_date
    end_datetime = end_date.acts_like?(:date) ? end_date.end_of_day : end_date

    where(arel_table[field].gteq(start_datetime).and(arel_table[field].lteq(end_datetime)))
  end
end
