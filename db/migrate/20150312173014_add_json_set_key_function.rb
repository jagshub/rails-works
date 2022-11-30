class AddJsonSetKeyFunction < ActiveRecord::Migration
  def up
    # Note (k1): https://gist.github.com/pozs/a632be48346ca2990a0e
    # "json_object_set_key" sets a key in a JSON object.

    execute(%q{
      CREATE OR REPLACE FUNCTION "json_object_set_key"(
        "json"          json,
        "key_to_set"    TEXT,
        "value_to_set"  anyelement
      )
        RETURNS json
        LANGUAGE sql
        IMMUTABLE
        STRICT
      AS $function$
      SELECT concat('{', string_agg(to_json("key") || ':' || "value", ','), '}')::json
        FROM (SELECT *
                FROM json_each("json")
               WHERE "key" <> "key_to_set"
               UNION ALL
              SELECT "key_to_set", to_json("value_to_set")) AS "fields"
      $function$;
    })
  end

  def down
    execute(%q{DROP FUNCTION IF EXISTS "json_object_set_key"(json, TEXT, anyelement)})
  end
end
