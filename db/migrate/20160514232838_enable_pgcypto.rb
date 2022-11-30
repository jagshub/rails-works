class EnablePgcypto < ActiveRecord::Migration
  def change
    # Note(Mike Coutermarsh): Used for generating uuid's.
    #   http://edgeguides.rubyonrails.org/active_record_postgresql.html#uuid-primary-keys
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
