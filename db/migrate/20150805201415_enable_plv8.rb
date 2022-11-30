class EnablePlv8 < ActiveRecord::Migration
  def change
    # Note(LukasFittl): We've since disabled plv8 again, this is commented out to
    #   enable "rake db:migrate:reset" on a barebone postgres install
    #enable_extension 'plv8'
  end
end
