# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  extend ActiveRecordDateHelper

  class << self
    def by_ordered_ids(ids)
      return none if ids.blank?

      ids_expression = ids.map(&:to_i).join(',')
      array_type = "#{ columns_hash['id'].sql_type }[]"

      order = sanitize_sql(["array_position(array[#{ ids_expression }]::#{ array_type }, #{ table_name }.id)"])
      where(id: ids).order(Arel.sql(order))
    end

    def extension(extension_module, *args)
      extension_module.define(self, *args)
    end

    def belongs_to_polymorphic(name, allowed_classes:, **options)
      belongs_to name, polymorphic: true, **options

      validates "#{ name }_type", inclusion: { in: allowed_classes.map(&:name), allow_nil: !!options[:optional] }

      define_singleton_method("#{ name }_types") { allowed_classes }

      define_singleton_method("with_#{ name }") do |type|
        type = case type
               when Class then type.name
               when String then type
               else type.class.name
               end
        where(arel_table["#{ name }_type".to_sym].eq(type))
      end

      allowed_classes.each do |model|
        scope "with_#{ name }_#{ model.name.underscore.tr('/', '_') }", lambda {
          where(arel_table["#{ name }_type".to_sym].eq(model.name))
        }
      end
    end

    # NOTE(DZ): For best `like` search results, use pg_trgm indexed column
    # add_index ... using: :gin, opclass: { title: :gin_trgm_ops }
    #
    def where_like(name, query)
      # NOTE(rstankov): Index for like work when `%` are only the right side
      where(
        arel_table[name]
          .lower
          .matches("#{ query.to_s.downcase.gsub(/\W+/, '%') }%"),
      )
    end

    def where_like_slow(name, query)
      where(
        arel_table[name]
          .lower
          .matches("%#{ query.to_s.downcase.gsub(/\W+/, '%') }%"),
      )
    end
  end
end
