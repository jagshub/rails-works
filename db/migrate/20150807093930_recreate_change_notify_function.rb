class RecreateChangeNotifyFunction < ActiveRecord::Migration
  def up
    # Note(LukasFittl): We've since disabled plv8 again, replaced plv8 with plpgsql
    #   version to enable "rake db:migrate:reset" on a barebone postgres install

    execute <<-SQL
      CREATE FUNCTION change_trigger_v2() RETURNS trigger
      LANGUAGE plpgsql
      AS $$
        DECLARE
        BEGIN
          PERFORM pg_notify('changes', json_build_object('table', TG_TABLE_NAME, 'type', TG_OP,
            'new', CASE WHEN TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN NEW ELSE NULL END,
            'old', CASE WHEN TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN OLD ELSE NULL END,
            'version', 2)::text);

          IF (TG_OP = 'DELETE') THEN
            RETURN OLD;
          ELSE
            RETURN NEW;
          END IF;
        END;
      $$;
    SQL

    # execute <<-SQL
    #   CREATE OR REPLACE FUNCTION change_trigger_v2() RETURNS trigger AS
    #   $$
    #       var event = {};
    #
    #       event.table = TG_TABLE_NAME;
    #       event.type = TG_OP;
    #       event.new = NEW || null;
    #       event.old = OLD || null;
    #       event.version = 2;
    #
    #       plv8.execute("SELECT pg_notify('changes', $1);", [ JSON.stringify(event) ]);
    #   $$
    #   LANGUAGE "plv8";
    # SQL
  end


  def down
    execute <<-SQL
      DROP FUNCTION IF EXISTS change_trigger_v2() CASCADE;
    SQL
  end
end
