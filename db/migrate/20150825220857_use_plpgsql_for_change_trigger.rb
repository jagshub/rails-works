class UsePlpgsqlForChangeTrigger < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION change_trigger_v2() RETURNS trigger AS $$
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
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute <<-SQL
      CREATE OR REPLACE FUNCTION change_trigger_v2() RETURNS trigger
      LANGUAGE plv8
      AS $_$
        var event = {};

        event.table = TG_TABLE_NAME;
        event.type = TG_OP;
        event.new = NEW || null;
        event.old = OLD || null;
        event.version = 2;

        plv8.execute("SELECT pg_notify('changes', $1);", [ JSON.stringify(event) ]);
      $_$;
    SQL
  end
end
