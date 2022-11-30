class AddComputeMinhashSignatureFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION compute_minhash_signature(k integer, ids integer[]) RETURNS hstore AS $$
        WITH
          base AS (SELECT hashint4(id) AS hash FROM unnest(ids) AS id),
          masks AS (SELECT setseed(log(i + 1, 2)), hashfloat8(random()) AS mask, i FROM generate_series(1, k) AS i)
        SELECT
          hstore(array_agg(i::text), array_agg(minhash.hash::text))
        FROM
          masks,
          LATERAL (
            SELECT base.hash # masks.mask AS hash FROM base ORDER BY hash ASC LIMIT 1
          ) AS minhash
      $$ LANGUAGE SQL
         IMMUTABLE;
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION IF EXISTS compute_minhash_signature(integer, integer[]);
    SQL
  end
end
