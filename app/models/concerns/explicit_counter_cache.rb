# frozen_string_literal: true

module ExplicitCounterCache
  extend ActiveSupport::Concern

  class_methods do
    attr_accessor :explicit_counter_columns

    # Defines a counter cache on the passed scope, which is accessible under
    # counter_name and can be refreshed by calling `refresh_<counter_name>`.
    #
    # Also defines an `async_refresh_<counter_name>` function that triggers a
    # background job invoking the above. This can be useful in cases where the
    # direct update is too slow and we don't need it immediately updated in the
    # UI.
    #
    # Note that there is no automatic update for counter caches defined this way,
    # since you'll likely want to use this if you run into locking issues with
    # Rails' built-in counter cache.
    def explicit_counter_cache(counter_name, scope)
      self.explicit_counter_columns ||= []
      self.explicit_counter_columns << counter_name

      define_method "refresh_#{ counter_name }" do
        return if destroyed?

        relation = instance_exec(&scope)
        new_count = relation.count

        return if self[counter_name] == new_count

        # Note (LukasFittl): We intentionally avoid callbacks/validations here
        #   since these might be too expensive in some cases, e.g. checking
        #   another field for uniqueness even though we're just updating a counter.
        update_columns counter_name => new_count, updated_at: Time.current
      end

      define_method "async_refresh_#{ counter_name }" do
        AsyncRefreshWorker.perform_later(self, counter_name.to_s)
      end
    end
  end

  included do
    def reset_explicit_counters
      return unless self.class.explicit_counter_columns

      self.class.explicit_counter_columns.each do |counter_name|
        public_send("refresh_#{ counter_name }")
      end
    end
  end
end
