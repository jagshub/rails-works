SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pganalyze; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pganalyze;


--
-- Name: pglogical; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pglogical;


--
-- Name: replication_schema; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA replication_schema;


--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: intarray; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS intarray WITH SCHEMA public;


--
-- Name: EXTENSION intarray; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION intarray IS 'functions, operators, and index support for 1-D arrays of integers';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: get_column_stats(); Type: FUNCTION; Schema: pganalyze; Owner: -
--

CREATE FUNCTION pganalyze.get_column_stats() RETURNS SETOF pg_stats
    LANGUAGE sql SECURITY DEFINER
    AS $$
  /* pganalyze-collector */ SELECT schemaname, tablename, attname, inherited, null_frac, avg_width,
    n_distinct, NULL::anyarray, most_common_freqs, NULL::anyarray, correlation, NULL::anyarray,
    most_common_elem_freqs, elem_count_histogram
  FROM pg_catalog.pg_stats;
$$;


--
-- Name: get_stat_replication(); Type: FUNCTION; Schema: pganalyze; Owner: -
--

CREATE FUNCTION pganalyze.get_stat_replication() RETURNS SETOF pg_stat_replication
    LANGUAGE sql SECURITY DEFINER
    AS $$
  /* pganalyze-collector */ SELECT * FROM pg_catalog.pg_stat_replication;
$$;


--
-- Name: awsdms_intercept_ddl(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.awsdms_intercept_ddl() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
  declare _qry text;
BEGIN
  if (tg_tag='CREATE TABLE' or tg_tag='ALTER TABLE' or tg_tag='DROP TABLE') then
	    SELECT current_query() into _qry;
	    insert into public.awsdms_ddl_audit
	    values
	    (
	    default,current_timestamp,current_user,cast(TXID_CURRENT()as varchar(16)),tg_tag,0,'',current_schema,_qry
	    );
	    delete from public.awsdms_ddl_audit;
 end if;
END;
$$;


--
-- Name: compute_minhash_signature(integer, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.compute_minhash_signature(k integer, ids integer[]) RETURNS public.hstore
    LANGUAGE sql IMMUTABLE
    AS $$
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
      $$;


--
-- Name: json_eq(json, json); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.json_eq(json, json) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    select $1::jsonb = $2::jsonb
$_$;


--
-- Name: json_gt(json, json); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.json_gt(json, json) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    select $1::jsonb > $2::jsonb
$_$;


--
-- Name: json_gte(json, json); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.json_gte(json, json) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    select $1::jsonb > $2::jsonb OR $1::jsonb = $2::jsonb
$_$;


--
-- Name: json_lt(json, json); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.json_lt(json, json) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    select $1::jsonb < $2::jsonb
$_$;


--
-- Name: json_lte(json, json); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.json_lte(json, json) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    select $1::jsonb < $2::jsonb OR $1::jsonb = $2::jsonb
$_$;


--
-- Name: jsoncmp(json, json); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.jsoncmp(json, json) RETURNS integer
    LANGUAGE sql IMMUTABLE
    AS $_$
    select case 
        when $1 = $2 then 0
        when $1 < $2 then -1
        else 1
    end
$_$;


--
-- Name: recompute_post_ids_minhash_signature_for_collection(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recompute_post_ids_minhash_signature_for_collection(cid integer) RETURNS void
    LANGUAGE sql
    AS $$
        UPDATE collections
        SET post_ids_minhash_signature = compute_minhash_signature(30, (SELECT array_agg(post_id) FROM collection_post_associations WHERE collection_id = cid))
        WHERE id = cid
      $$;


--
-- Name: recompute_post_ids_minhash_signature_for_collection_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recompute_post_ids_minhash_signature_for_collection_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
        BEGIN
          PERFORM recompute_post_ids_minhash_signature_for_collection(CASE WHEN TG_OP = 'INSERT' THEN NEW.collection_id ELSE OLD.collection_id END);
          RETURN NULL;
        END;
      $$;


--
-- Name: recompute_post_ids_minhash_signature_for_tag_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recompute_post_ids_minhash_signature_for_tag_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
        BEGIN
          PERFORM recompute_post_ids_minhash_signature_for_tag(CASE WHEN TG_OP = 'INSERT' THEN NEW.tag_id ELSE OLD.tag_id END);
          RETURN NULL;
        END;
      $$;


--
-- Name: recompute_post_ids_minhash_signature_for_topic(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recompute_post_ids_minhash_signature_for_topic(tid integer) RETURNS void
    LANGUAGE sql
    AS $$
        UPDATE topics
        SET post_ids_minhash_signature = compute_minhash_signature(30, (SELECT array_agg(post_id) FROM post_topic_associations WHERE topic_id = tid))
        WHERE id = tid
      $$;


--
-- Name: recompute_post_ids_minhash_signature_for_topic_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.recompute_post_ids_minhash_signature_for_topic_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
        BEGIN
          PERFORM recompute_post_ids_minhash_signature_for_topic(CASE WHEN TG_OP = 'INSERT' THEN NEW.topic_id ELSE OLD.topic_id END);
          RETURN NULL;
        END;
      $$;


--
-- Name: awsdms_intercept_ddl(); Type: FUNCTION; Schema: replication_schema; Owner: -
--

CREATE FUNCTION replication_schema.awsdms_intercept_ddl() RETURNS event_trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  declare _qry text;
BEGIN
  if (tg_tag='CREATE TABLE' or tg_tag='ALTER TABLE' or tg_tag='DROP TABLE') then
         SELECT current_query() into _qry;
         insert into replication_schema.awsdms_ddl_audit
         values
         (
         default,current_timestamp,current_user,cast(TXID_CURRENT()as varchar(16)),tg_tag,0,'',current_schema,_qry
         );
         delete from replication_schema.awsdms_ddl_audit;
end if;
END;
$$;


--
-- Name: <; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.< (
    FUNCTION = public.json_lt,
    LEFTARG = json,
    RIGHTARG = json
);


--
-- Name: <=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.<= (
    FUNCTION = public.json_lte,
    LEFTARG = json,
    RIGHTARG = json
);


--
-- Name: =; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.= (
    FUNCTION = public.json_eq,
    LEFTARG = json,
    RIGHTARG = json
);


--
-- Name: >; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.> (
    FUNCTION = public.json_gt,
    LEFTARG = json,
    RIGHTARG = json
);


--
-- Name: >=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR public.>= (
    FUNCTION = public.json_gte,
    LEFTARG = json,
    RIGHTARG = json
);


--
-- Name: json_ops; Type: OPERATOR FAMILY; Schema: public; Owner: -
--

CREATE OPERATOR FAMILY public.json_ops USING btree;


--
-- Name: json_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS public.json_ops
    DEFAULT FOR TYPE json USING btree FAMILY public.json_ops AS
    OPERATOR 1 public.<(json,json) ,
    OPERATOR 2 public.<=(json,json) ,
    OPERATOR 3 public.=(json,json) ,
    OPERATOR 4 public.>=(json,json) ,
    OPERATOR 5 public.>(json,json) ,
    FUNCTION 1 (json, json) public.jsoncmp(json,json);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ab_test_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ab_test_participants (
    id bigint NOT NULL,
    variant character varying NOT NULL,
    user_id bigint,
    visitor_id character varying,
    anonymous_id character varying,
    completed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    test_name character varying
);


--
-- Name: ab_test_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ab_test_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ab_test_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ab_test_participants_id_seq OWNED BY public.ab_test_participants.id;


--
-- Name: access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    token_type integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone,
    unavailable_until timestamp without time zone,
    permissions integer DEFAULT 0 NOT NULL,
    token text,
    secret text
);


--
-- Name: access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.access_tokens_id_seq OWNED BY public.access_tokens.id;


--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_admin_comments (
    id integer NOT NULL,
    namespace character varying(255),
    body text,
    resource_id character varying(255) NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_admin_comments_id_seq OWNED BY public.active_admin_comments.id;


--
-- Name: ads_budgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ads_budgets (
    id bigint NOT NULL,
    campaign_id bigint NOT NULL,
    kind character varying NOT NULL,
    channels_count integer DEFAULT 0 NOT NULL,
    active_channels_count integer DEFAULT 0 NOT NULL,
    amount numeric(15,2) NOT NULL,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit_price numeric(8,2),
    closes_count integer DEFAULT 0 NOT NULL,
    clicks_count integer DEFAULT 0 NOT NULL,
    impressions_count integer DEFAULT 0 NOT NULL,
    active_start_hour integer DEFAULT 0 NOT NULL,
    active_end_hour integer DEFAULT 23,
    daily_cap_amount numeric(15,2) DEFAULT 0.0 NOT NULL,
    today_impressions_count integer DEFAULT 0 NOT NULL,
    today_cap_reached boolean DEFAULT false NOT NULL,
    today_date character varying,
    name character varying,
    tagline character varying,
    thumbnail_uuid character varying,
    cta_text character varying,
    url character varying,
    url_params json DEFAULT '{}'::json
);


--
-- Name: ads_budgets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ads_budgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ads_budgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ads_budgets_id_seq OWNED BY public.ads_budgets.id;


--
-- Name: ads_campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ads_campaigns (
    id bigint NOT NULL,
    post_id bigint,
    name character varying NOT NULL,
    tagline character varying NOT NULL,
    thumbnail_uuid character varying NOT NULL,
    url character varying NOT NULL,
    url_params json DEFAULT '{}'::json NOT NULL,
    budgets_count integer DEFAULT 0 NOT NULL,
    active_budgets_count integer DEFAULT 0 NOT NULL,
    cta_text character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ads_campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ads_campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ads_campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ads_campaigns_id_seq OWNED BY public.ads_campaigns.id;


--
-- Name: ads_channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ads_channels (
    id bigint NOT NULL,
    budget_id bigint NOT NULL,
    kind character varying NOT NULL,
    bundle character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    closes_count integer DEFAULT 0 NOT NULL,
    clicks_count integer DEFAULT 0 NOT NULL,
    impressions_count integer DEFAULT 0 NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    url character varying NOT NULL,
    url_params json DEFAULT '{}'::json NOT NULL,
    application character varying DEFAULT 'all_apps'::character varying NOT NULL,
    name character varying,
    tagline character varying,
    thumbnail_uuid character varying
);


--
-- Name: ads_channels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ads_channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ads_channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ads_channels_id_seq OWNED BY public.ads_channels.id;


--
-- Name: ads_interactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ads_interactions (
    id bigint NOT NULL,
    channel_id bigint NOT NULL,
    user_id bigint,
    track_code character varying NOT NULL,
    kind character varying NOT NULL,
    reference character varying,
    ip_address character varying,
    user_agent character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    backfill_at timestamp without time zone
);


--
-- Name: ads_interactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ads_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ads_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ads_interactions_id_seq OWNED BY public.ads_interactions.id;


--
-- Name: ads_newsletter_interactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ads_newsletter_interactions (
    id bigint NOT NULL,
    ads_newsletter_id bigint,
    user_id bigint,
    kind character varying NOT NULL,
    user_agent character varying,
    is_bot boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    subject_type character varying,
    subject_id bigint,
    ip_address character varying,
    visitor_id character varying
);


--
-- Name: ads_newsletter_interactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ads_newsletter_interactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ads_newsletter_interactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ads_newsletter_interactions_id_seq OWNED BY public.ads_newsletter_interactions.id;


--
-- Name: ads_newsletter_sponsors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ads_newsletter_sponsors (
    id bigint NOT NULL,
    budget_id bigint,
    image_uuid character varying NOT NULL,
    url character varying NOT NULL,
    url_params json DEFAULT '{}'::json NOT NULL,
    description_html character varying NOT NULL,
    cta character varying,
    active boolean DEFAULT true NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    opens_count integer DEFAULT 0 NOT NULL,
    clicks_count integer DEFAULT 0 NOT NULL,
    sents_count integer DEFAULT 0 NOT NULL,
    body_image_uuid character varying
);


--
-- Name: ads_newsletter_sponsors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ads_newsletter_sponsors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ads_newsletter_sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ads_newsletter_sponsors_id_seq OWNED BY public.ads_newsletter_sponsors.id;


--
-- Name: ads_newsletters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ads_newsletters (
    id bigint NOT NULL,
    budget_id bigint NOT NULL,
    newsletter_id bigint,
    name character varying NOT NULL,
    tagline character varying NOT NULL,
    thumbnail_uuid character varying NOT NULL,
    url character varying NOT NULL,
    url_params json DEFAULT '{}'::json NOT NULL,
    opens_count integer DEFAULT 0 NOT NULL,
    clicks_count integer DEFAULT 0 NOT NULL,
    sents_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true
);


--
-- Name: ads_newsletters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ads_newsletters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ads_newsletters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ads_newsletters_id_seq OWNED BY public.ads_newsletters.id;


--
-- Name: anthologies_related_story_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.anthologies_related_story_associations (
    id bigint NOT NULL,
    story_id bigint,
    related_id bigint,
    "position" integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: anthologies_related_story_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.anthologies_related_story_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anthologies_related_story_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.anthologies_related_story_associations_id_seq OWNED BY public.anthologies_related_story_associations.id;


--
-- Name: anthologies_stories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.anthologies_stories (
    id integer NOT NULL,
    title character varying NOT NULL,
    slug character varying NOT NULL,
    header_image_uuid character varying,
    mins_to_read integer DEFAULT 0,
    description character varying,
    body_html text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    published_at timestamp without time zone,
    header_image_credit character varying,
    category character varying NOT NULL,
    featured_position integer,
    social_image_uuid character varying,
    author_name character varying,
    author_url character varying
);


--
-- Name: anthologies_stories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.anthologies_stories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anthologies_stories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.anthologies_stories_id_seq OWNED BY public.anthologies_stories.id;


--
-- Name: anthologies_story_mentions_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.anthologies_story_mentions_associations (
    id bigint NOT NULL,
    story_id bigint NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: anthologies_story_mentions_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.anthologies_story_mentions_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anthologies_story_mentions_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.anthologies_story_mentions_associations_id_seq OWNED BY public.anthologies_story_mentions_associations.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audits (
    id bigint NOT NULL,
    auditable_id integer,
    auditable_type character varying,
    associated_id integer,
    associated_type character varying,
    user_id integer,
    user_type character varying,
    username character varying,
    action character varying,
    audited_changes text,
    version integer DEFAULT 0,
    comment character varying,
    remote_address character varying,
    request_uuid character varying,
    created_at timestamp without time zone
);


--
-- Name: audits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audits_id_seq OWNED BY public.audits.id;


--
-- Name: awsdms_ddl_audit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.awsdms_ddl_audit (
    c_key bigint NOT NULL,
    c_time timestamp without time zone,
    c_user character varying(64),
    c_txn character varying(16),
    c_tag character varying(24),
    c_oid integer,
    c_name character varying(64),
    c_schema character varying(64),
    c_ddlqry text
);


--
-- Name: awsdms_ddl_audit_c_key_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.awsdms_ddl_audit_c_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: awsdms_ddl_audit_c_key_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.awsdms_ddl_audit_c_key_seq OWNED BY public.awsdms_ddl_audit.c_key;


--
-- Name: badges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.badges (
    id integer NOT NULL,
    subject_id integer NOT NULL,
    subject_type character varying NOT NULL,
    type character varying NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: badges_awards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.badges_awards (
    id bigint NOT NULL,
    identifier character varying NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    image_uuid character varying NOT NULL,
    active boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: badges_awards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.badges_awards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: badges_awards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.badges_awards_id_seq OWNED BY public.badges_awards.id;


--
-- Name: badges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.badges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: badges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.badges_id_seq OWNED BY public.badges.id;


--
-- Name: banners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.banners (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    "position" character varying DEFAULT 'mainfeed'::character varying NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    description text,
    desktop_image_uuid character varying NOT NULL,
    wide_image_uuid character varying NOT NULL,
    tablet_image_uuid character varying NOT NULL,
    mobile_image_uuid character varying NOT NULL,
    url character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: banners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.banners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: banners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.banners_id_seq OWNED BY public.banners.id;


--
-- Name: browser_extension_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.browser_extension_settings (
    id bigint NOT NULL,
    user_id bigint,
    visitor_id character varying,
    background_image_mode boolean DEFAULT false NOT NULL,
    beta_mode boolean DEFAULT false NOT NULL,
    dark_mode boolean DEFAULT false NOT NULL,
    home_view_variant character varying(32) DEFAULT 'grid'::character varying NOT NULL,
    show_goals_and_co_working boolean DEFAULT false NOT NULL,
    show_random_product boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    locality character varying
);


--
-- Name: browser_extension_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.browser_extension_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: browser_extension_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.browser_extension_settings_id_seq OWNED BY public.browser_extension_settings.id;


--
-- Name: change_log_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_log_entries (
    id bigint NOT NULL,
    slug character varying NOT NULL,
    state character varying DEFAULT 'pending'::character varying NOT NULL,
    title character varying NOT NULL,
    description_md text,
    date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    major_update boolean DEFAULT false NOT NULL,
    has_discussion boolean DEFAULT false NOT NULL,
    discussion_thread_id bigint,
    notification_sent boolean DEFAULT false NOT NULL,
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    description_html text
);


--
-- Name: change_log_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_log_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_log_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_log_entries_id_seq OWNED BY public.change_log_entries.id;


--
-- Name: checkout_page_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checkout_page_logs (
    id integer NOT NULL,
    checkout_page_id integer NOT NULL,
    user_id integer NOT NULL,
    billing_email character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: checkout_page_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checkout_page_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkout_page_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checkout_page_logs_id_seq OWNED BY public.checkout_page_logs.id;


--
-- Name: checkout_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checkout_pages (
    id integer NOT NULL,
    name character varying NOT NULL,
    sku character varying NOT NULL,
    slug character varying NOT NULL,
    body text NOT NULL,
    trashed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    kind integer DEFAULT 0
);


--
-- Name: checkout_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checkout_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checkout_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checkout_pages_id_seq OWNED BY public.checkout_pages.id;


--
-- Name: clearbit_company_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clearbit_company_profiles (
    id bigint NOT NULL,
    domain character varying NOT NULL,
    name character varying,
    clearbit_id character varying NOT NULL,
    legal_name character varying,
    category_sector character varying,
    category_industry character varying,
    category_sub_industry character varying,
    geo_country character varying,
    metrics_employees character varying,
    metrics_employees_range character varying,
    metrics_estimated_annual_revenue character varying,
    founded_year character varying,
    indexed_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: clearbit_company_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clearbit_company_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clearbit_company_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clearbit_company_profiles_id_seq OWNED BY public.clearbit_company_profiles.id;


--
-- Name: clearbit_people_companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clearbit_people_companies (
    id bigint NOT NULL,
    person_id bigint NOT NULL,
    company_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: clearbit_people_companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clearbit_people_companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clearbit_people_companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clearbit_people_companies_id_seq OWNED BY public.clearbit_people_companies.id;


--
-- Name: clearbit_person_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clearbit_person_profiles (
    id integer NOT NULL,
    clearbit_id character varying NOT NULL,
    email character varying NOT NULL,
    indexed_at timestamp without time zone NOT NULL,
    name character varying,
    gender character varying,
    bio text,
    site character varying,
    avatar_url character varying,
    employment_name character varying,
    employment_title character varying,
    employment_domain character varying,
    geo_city character varying,
    geo_state character varying,
    geo_country character varying,
    github_handle character varying,
    twitter_handle character varying,
    linkedin_handle character varying,
    gravatar_handle character varying,
    aboutme_handle character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    employment_seniority character varying,
    employment_role character varying
);


--
-- Name: clearbit_person_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clearbit_person_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clearbit_person_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clearbit_person_profiles_id_seq OWNED BY public.clearbit_person_profiles.id;


--
-- Name: collection_curator_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_curator_associations (
    id integer NOT NULL,
    user_id integer NOT NULL,
    collection_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: collection_curator_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_curator_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_curator_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_curator_associations_id_seq OWNED BY public.collection_curator_associations.id;


--
-- Name: collection_post_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_post_associations (
    id integer NOT NULL,
    collection_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: collection_post_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_post_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_post_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_post_associations_id_seq OWNED BY public.collection_post_associations.id;


--
-- Name: collection_product_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_product_associations (
    id bigint NOT NULL,
    collection_id bigint NOT NULL,
    product_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: collection_product_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_product_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_product_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_product_associations_id_seq OWNED BY public.collection_product_associations.id;


--
-- Name: collection_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_subscriptions (
    id integer NOT NULL,
    user_id integer,
    collection_id integer NOT NULL,
    email character varying,
    state integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: collection_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_subscriptions_id_seq OWNED BY public.collection_subscriptions.id;


--
-- Name: collection_topic_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_topic_associations (
    id integer NOT NULL,
    collection_id integer NOT NULL,
    topic_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: collection_topic_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_topic_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_topic_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_topic_associations_id_seq OWNED BY public.collection_topic_associations.id;


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id integer NOT NULL,
    user_id integer NOT NULL,
    slug character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    title character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    featured_at timestamp without time zone,
    subscriber_count integer DEFAULT 0 NOT NULL,
    last_post_added_at timestamp without time zone,
    post_ids_minhash_signature public.hstore,
    image_uuid character varying,
    intro_html text,
    recap_html text,
    personal boolean DEFAULT false NOT NULL,
    description text,
    products_count integer DEFAULT 0 NOT NULL,
    last_product_added_at timestamp without time zone
);


--
-- Name: collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collections_id_seq OWNED BY public.collections.id;


--
-- Name: comment_awards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_awards (
    id bigint NOT NULL,
    kind character varying NOT NULL,
    comment_id bigint NOT NULL,
    awarded_by_id bigint NOT NULL,
    awarded_to_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: comment_awards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comment_awards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_awards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comment_awards_id_seq OWNED BY public.comment_awards.id;


--
-- Name: comment_prompts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_prompts (
    id bigint NOT NULL,
    prompt character varying NOT NULL,
    post_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: comment_prompts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comment_prompts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_prompts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comment_prompts_id_seq OWNED BY public.comment_prompts.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    user_id integer,
    body text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    parent_comment_id integer,
    subject_type text,
    subject_id integer,
    sticky boolean DEFAULT false NOT NULL,
    mentioned_user_ids integer[] DEFAULT '{}'::integer[],
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    hidden_at timestamp without time zone,
    replies_count integer DEFAULT 0 NOT NULL,
    user_flags_count integer DEFAULT 0,
    trashed_at timestamp without time zone,
    total_votes_count integer DEFAULT 0 NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: cookie_policy_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cookie_policy_logs (
    id integer NOT NULL,
    ip_address character varying NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cookie_policy_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cookie_policy_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cookie_policy_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cookie_policy_logs_id_seq OWNED BY public.cookie_policy_logs.id;


--
-- Name: crypto_currency_trackers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crypto_currency_trackers (
    id bigint NOT NULL,
    token_id integer NOT NULL,
    token_symbol character varying NOT NULL,
    token_name character varying NOT NULL,
    usd_price numeric(12,2),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: crypto_currency_trackers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crypto_currency_trackers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crypto_currency_trackers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crypto_currency_trackers_id_seq OWNED BY public.crypto_currency_trackers.id;


--
-- Name: disabled_friend_syncs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disabled_friend_syncs (
    id integer NOT NULL,
    followed_by_user_id integer NOT NULL,
    following_user_id integer NOT NULL
);


--
-- Name: disabled_friend_syncs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disabled_friend_syncs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disabled_friend_syncs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disabled_friend_syncs_id_seq OWNED BY public.disabled_friend_syncs.id;


--
-- Name: disabled_twitter_syncs; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.disabled_twitter_syncs AS
 SELECT disabled_friend_syncs.id,
    disabled_friend_syncs.followed_by_user_id,
    disabled_friend_syncs.following_user_id
   FROM public.disabled_friend_syncs;


--
-- Name: discussion_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.discussion_categories (
    id bigint NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    description character varying DEFAULT ''::character varying NOT NULL,
    thumbnail_uuid character varying,
    discussion_thread_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: discussion_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.discussion_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discussion_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.discussion_categories_id_seq OWNED BY public.discussion_categories.id;


--
-- Name: discussion_category_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.discussion_category_associations (
    id bigint NOT NULL,
    category_id bigint NOT NULL,
    discussion_thread_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: discussion_category_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.discussion_category_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discussion_category_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.discussion_category_associations_id_seq OWNED BY public.discussion_category_associations.id;


--
-- Name: discussion_threads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.discussion_threads (
    id integer NOT NULL,
    title character varying NOT NULL,
    description text,
    comments_count integer DEFAULT 0 NOT NULL,
    trashed_at timestamp without time zone,
    subject_type character varying NOT NULL,
    subject_id integer NOT NULL,
    user_id integer NOT NULL,
    anonymous boolean DEFAULT false NOT NULL,
    pinned boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hidden_at timestamp without time zone,
    social_image_url character varying,
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    featured_at date,
    trending_at date,
    approved_at timestamp without time zone,
    slug character varying NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL
);


--
-- Name: discussion_threads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.discussion_threads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discussion_threads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.discussion_threads_id_seq OWNED BY public.discussion_threads.id;


--
-- Name: dismissables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dismissables (
    id integer NOT NULL,
    dismissable_group character varying NOT NULL,
    dismissable_key character varying NOT NULL,
    user_id integer NOT NULL,
    dismissed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: dismissables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dismissables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dismissables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dismissables_id_seq OWNED BY public.dismissables.id;


--
-- Name: drip_mails_scheduled_mails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drip_mails_scheduled_mails (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    mailer_name character varying NOT NULL,
    drip_kind character varying NOT NULL,
    send_on timestamp without time zone NOT NULL,
    completed boolean DEFAULT false,
    sent_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    subject_type character varying NOT NULL,
    subject_id integer NOT NULL,
    delivering boolean DEFAULT false
);


--
-- Name: drip_mails_scheduled_mails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drip_mails_scheduled_mails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drip_mails_scheduled_mails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drip_mails_scheduled_mails_id_seq OWNED BY public.drip_mails_scheduled_mails.id;


--
-- Name: email_provider_domains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_provider_domains (
    id bigint NOT NULL,
    value character varying NOT NULL,
    added_by_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: email_provider_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_provider_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_provider_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_provider_domains_id_seq OWNED BY public.email_provider_domains.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emails (
    id integer NOT NULL,
    email public.citext NOT NULL,
    source_kind character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source_reference_id character varying
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.emails_id_seq OWNED BY public.emails.id;


--
-- Name: embeds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.embeds (
    id integer NOT NULL,
    clean_url character varying,
    provider integer NOT NULL,
    title character varying,
    description character varying,
    author character varying,
    rating numeric(3,2),
    price numeric(8,2),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source text,
    url character varying,
    link_type integer DEFAULT 0 NOT NULL,
    favicon_image_uuid character varying,
    subject_id integer NOT NULL,
    subject_type character varying NOT NULL
);


--
-- Name: embeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.embeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: embeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.embeds_id_seq OWNED BY public.embeds.id;


--
-- Name: external_api_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_api_responses (
    id bigint NOT NULL,
    kind character varying NOT NULL,
    params jsonb DEFAULT '{}'::jsonb NOT NULL,
    response json DEFAULT '{}'::json NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: external_api_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.external_api_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_api_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.external_api_responses_id_seq OWNED BY public.external_api_responses.id;


--
-- Name: file_exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_exports (
    id integer NOT NULL,
    user_id integer NOT NULL,
    file_key character varying NOT NULL,
    file_name character varying NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    note character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: file_exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_exports_id_seq OWNED BY public.file_exports.id;


--
-- Name: flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flags (
    id integer NOT NULL,
    subject_type text NOT NULL,
    subject_id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status character varying DEFAULT 'unresolved'::character varying NOT NULL,
    reason character varying NOT NULL,
    moderator_id bigint,
    other_flags_count integer DEFAULT 0 NOT NULL
);


--
-- Name: flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flags_id_seq OWNED BY public.flags.id;


--
-- Name: flipper_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flipper_features (
    id integer NOT NULL,
    key character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: flipper_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flipper_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flipper_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flipper_features_id_seq OWNED BY public.flipper_features.id;


--
-- Name: flipper_gates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flipper_gates (
    id integer NOT NULL,
    feature_key character varying NOT NULL,
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: flipper_gates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flipper_gates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flipper_gates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flipper_gates_id_seq OWNED BY public.flipper_gates.id;


--
-- Name: founder_club_access_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.founder_club_access_requests (
    id integer NOT NULL,
    email character varying NOT NULL,
    user_id integer,
    deal_id integer,
    invite_code character varying NOT NULL,
    received_code_at timestamp without time zone,
    used_code_at timestamp without time zone,
    subscribed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source integer DEFAULT 0 NOT NULL,
    invited_by_user_id integer,
    expire_at timestamp without time zone,
    payment_discount_id bigint
);


--
-- Name: founder_club_access_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.founder_club_access_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: founder_club_access_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.founder_club_access_requests_id_seq OWNED BY public.founder_club_access_requests.id;


--
-- Name: founder_club_claims; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.founder_club_claims (
    id integer NOT NULL,
    deal_id integer NOT NULL,
    user_id integer NOT NULL,
    redemption_code_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: founder_club_claims_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.founder_club_claims_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: founder_club_claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.founder_club_claims_id_seq OWNED BY public.founder_club_claims.id;


--
-- Name: founder_club_deals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.founder_club_deals (
    id integer NOT NULL,
    title character varying NOT NULL,
    logo_uuid character varying,
    value character varying NOT NULL,
    summary character varying NOT NULL,
    redemption_url character varying NOT NULL,
    details text NOT NULL,
    terms text NOT NULL,
    how_to_claim text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    trashed_at timestamp without time zone,
    priority integer DEFAULT 0 NOT NULL,
    badges character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    redemption_method integer DEFAULT 0,
    claims_count integer DEFAULT 0,
    logo_with_colors_uuid character varying,
    company_name character varying,
    product_id bigint
);


--
-- Name: founder_club_deals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.founder_club_deals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: founder_club_deals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.founder_club_deals_id_seq OWNED BY public.founder_club_deals.id;


--
-- Name: founder_club_redemption_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.founder_club_redemption_codes (
    id integer NOT NULL,
    deal_id integer NOT NULL,
    code character varying,
    kind integer DEFAULT 0 NOT NULL,
    "limit" integer DEFAULT 1 NOT NULL,
    claims_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: founder_club_redemption_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.founder_club_redemption_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: founder_club_redemption_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.founder_club_redemption_codes_id_seq OWNED BY public.founder_club_redemption_codes.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id integer NOT NULL,
    slug character varying(255) NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying(255),
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: funding_surveys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funding_surveys (
    id bigint NOT NULL,
    post_id bigint,
    have_raised_vc_funding boolean,
    funding_round character varying,
    funding_amount character varying,
    interested_in_vc_funding boolean,
    interested_in_being_contacted boolean,
    share_with_investors boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: funding_surveys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.funding_surveys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: funding_surveys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.funding_surveys_id_seq OWNED BY public.funding_surveys.id;


--
-- Name: goals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.goals (
    id integer NOT NULL,
    completed_at timestamp without time zone,
    comments_count integer DEFAULT 0 NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    due_at timestamp without time zone,
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    maker_group_id integer NOT NULL,
    social_image_url character varying,
    title_html text,
    current boolean DEFAULT false NOT NULL,
    current_until timestamp without time zone,
    focused_duration integer DEFAULT 0,
    current_started timestamp without time zone,
    source character varying,
    hidden_at timestamp without time zone,
    feed_date date NOT NULL,
    trending_at date
);


--
-- Name: goals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.goals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: goals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.goals_id_seq OWNED BY public.goals.id;


--
-- Name: golden_kitty_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.golden_kitty_categories (
    id integer NOT NULL,
    name character varying NOT NULL,
    tagline character varying,
    emoji character varying,
    nomination_question character varying,
    year integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    topic_id integer,
    sponsor_id integer,
    priority integer DEFAULT 0 NOT NULL,
    slug character varying,
    voting_enabled_at timestamp without time zone,
    social_image_uuid character varying,
    edition_id bigint,
    social_image_nomination_uuid character varying,
    social_image_voting_uuid character varying,
    social_image_result_uuid character varying,
    social_image_pre_voting_uuid character varying,
    social_image_pre_result_uuid character varying,
    icon_uuid character varying,
    people_category boolean DEFAULT false NOT NULL
);


--
-- Name: golden_kitty_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.golden_kitty_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: golden_kitty_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.golden_kitty_categories_id_seq OWNED BY public.golden_kitty_categories.id;


--
-- Name: golden_kitty_edition_sponsors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.golden_kitty_edition_sponsors (
    id bigint NOT NULL,
    edition_id bigint NOT NULL,
    sponsor_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: golden_kitty_edition_sponsors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.golden_kitty_edition_sponsors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: golden_kitty_edition_sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.golden_kitty_edition_sponsors_id_seq OWNED BY public.golden_kitty_edition_sponsors.id;


--
-- Name: golden_kitty_editions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.golden_kitty_editions (
    id bigint NOT NULL,
    year integer NOT NULL,
    social_share_text character varying,
    nomination_starts_at timestamp without time zone NOT NULL,
    nomination_ends_at timestamp without time zone NOT NULL,
    voting_starts_at timestamp without time zone NOT NULL,
    voting_ends_at timestamp without time zone NOT NULL,
    result_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    social_text_nomination_started character varying,
    social_text_nomination_ended character varying,
    social_text_voting_started character varying,
    social_text_voting_ended character varying,
    social_text_result_announced character varying,
    subscribers_count integer DEFAULT 0 NOT NULL,
    followers_count integer DEFAULT 0 NOT NULL,
    social_image_uuid character varying,
    social_image_nomination_uuid character varying,
    social_image_voting_uuid character varying,
    social_image_result_uuid character varying,
    social_image_pre_voting_uuid character varying,
    social_image_pre_result_uuid character varying,
    results_url character varying,
    results_description character varying,
    live_event_at timestamp without time zone,
    card_image_uuid character varying
);


--
-- Name: golden_kitty_editions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.golden_kitty_editions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: golden_kitty_editions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.golden_kitty_editions_id_seq OWNED BY public.golden_kitty_editions.id;


--
-- Name: golden_kitty_facts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.golden_kitty_facts (
    id bigint NOT NULL,
    image_uuid character varying NOT NULL,
    description character varying NOT NULL,
    category_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: golden_kitty_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.golden_kitty_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: golden_kitty_facts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.golden_kitty_facts_id_seq OWNED BY public.golden_kitty_facts.id;


--
-- Name: golden_kitty_finalists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.golden_kitty_finalists (
    id integer NOT NULL,
    post_id integer NOT NULL,
    golden_kitty_category_id integer NOT NULL,
    winner boolean DEFAULT false NOT NULL,
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "position" integer
);


--
-- Name: golden_kitty_finalists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.golden_kitty_finalists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: golden_kitty_finalists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.golden_kitty_finalists_id_seq OWNED BY public.golden_kitty_finalists.id;


--
-- Name: golden_kitty_nominees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.golden_kitty_nominees (
    id integer NOT NULL,
    golden_kitty_category_id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    comment character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: golden_kitty_nominees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.golden_kitty_nominees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: golden_kitty_nominees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.golden_kitty_nominees_id_seq OWNED BY public.golden_kitty_nominees.id;


--
-- Name: golden_kitty_people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.golden_kitty_people (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    golden_kitty_category_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    winner boolean DEFAULT false NOT NULL,
    "position" integer
);


--
-- Name: golden_kitty_people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.golden_kitty_people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: golden_kitty_people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.golden_kitty_people_id_seq OWNED BY public.golden_kitty_people.id;


--
-- Name: golden_kitty_sponsors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.golden_kitty_sponsors (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description character varying NOT NULL,
    url character varying NOT NULL,
    website character varying NOT NULL,
    logo_uuid character varying NOT NULL,
    left_image_uuid character varying,
    right_image_uuid character varying,
    dark_ui boolean DEFAULT true NOT NULL,
    bg_color character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: golden_kitty_sponsors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.golden_kitty_sponsors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: golden_kitty_sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.golden_kitty_sponsors_id_seq OWNED BY public.golden_kitty_sponsors.id;


--
-- Name: highlighted_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.highlighted_changes (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    title character varying,
    body text,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    desktop_image_uuid character varying,
    tablet_image_uuid character varying,
    mobile_image_uuid character varying,
    cta_text character varying,
    cta_url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    platform character varying DEFAULT 'desktop'::character varying NOT NULL
);


--
-- Name: highlighted_changes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.highlighted_changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: highlighted_changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.highlighted_changes_id_seq OWNED BY public.highlighted_changes.id;


--
-- Name: house_keeper_broken_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.house_keeper_broken_links (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    product_link_id bigint NOT NULL,
    reason text
);


--
-- Name: house_keeper_broken_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.house_keeper_broken_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: house_keeper_broken_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.house_keeper_broken_links_id_seq OWNED BY public.house_keeper_broken_links.id;


--
-- Name: input_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.input_suggestions (
    id integer NOT NULL,
    name public.citext NOT NULL,
    kind integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_id integer
);


--
-- Name: input_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.input_suggestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: input_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.input_suggestions_id_seq OWNED BY public.input_suggestions.id;


--
-- Name: iterable_event_webhook_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.iterable_event_webhook_data (
    id bigint NOT NULL,
    event_name character varying NOT NULL,
    email character varying,
    workflow_name character varying,
    campaign_name character varying,
    data_fields jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: iterable_event_webhook_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.iterable_event_webhook_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: iterable_event_webhook_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.iterable_event_webhook_data_id_seq OWNED BY public.iterable_event_webhook_data.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id integer NOT NULL,
    image_uuid text NOT NULL,
    company_name text NOT NULL,
    job_title text NOT NULL,
    url text NOT NULL,
    published boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    remote_ok boolean DEFAULT false NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    company_jobs_url character varying,
    company_tagline character varying,
    job_type character varying,
    external_id integer,
    external_created_at timestamp without time zone DEFAULT now(),
    kind integer DEFAULT 0 NOT NULL,
    slug character varying,
    token character varying,
    user_id integer,
    stripe_customer_id character varying,
    stripe_billing_email character varying,
    stripe_subscription_id character varying,
    cancelled_at timestamp without time zone,
    email character varying,
    jobs_discount_page_id integer,
    billing_cycle_anchor timestamp without time zone,
    trashed_at timestamp without time zone,
    renew_notice_sent_at timestamp without time zone,
    extra_packages character varying[],
    last_payment_at timestamp without time zone,
    extra_package_flags jsonb,
    product_id bigint
);


--
-- Name: jobs_discount_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs_discount_pages (
    id integer NOT NULL,
    name character varying NOT NULL,
    text text NOT NULL,
    slug character varying,
    discount_value integer DEFAULT 0 NOT NULL,
    discount_plan_ids character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    jobs_count integer DEFAULT 0 NOT NULL,
    trashed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: jobs_discount_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_discount_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_discount_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_discount_pages_id_seq OWNED BY public.jobs_discount_pages.id;


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: legacy_product_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_product_links (
    id integer NOT NULL,
    url text NOT NULL,
    short_code text NOT NULL,
    store integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id integer NOT NULL,
    primary_link boolean DEFAULT false NOT NULL,
    clean_url text,
    product_id integer,
    rating numeric(3,2),
    price numeric(8,2),
    devices character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    broken boolean DEFAULT false NOT NULL,
    post_id integer
);


--
-- Name: legacy_product_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.legacy_product_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: legacy_product_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.legacy_product_links_id_seq OWNED BY public.legacy_product_links.id;


--
-- Name: legacy_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legacy_products (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state integer DEFAULT 0 NOT NULL,
    angellist_url character varying,
    twitter_url character varying,
    instagram_url character varying,
    github_url character varying,
    facebook_url character varying,
    medium_url character varying
);


--
-- Name: legacy_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.legacy_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: legacy_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.legacy_products_id_seq OWNED BY public.legacy_products.id;


--
-- Name: link_spect_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.link_spect_logs (
    id bigint NOT NULL,
    external_link character varying NOT NULL,
    blocked boolean DEFAULT false NOT NULL,
    source integer DEFAULT 0 NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: link_spect_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.link_spect_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_spect_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.link_spect_logs_id_seq OWNED BY public.link_spect_logs.id;


--
-- Name: link_trackers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.link_trackers (
    id integer NOT NULL,
    post_id integer,
    user_id integer,
    track_code character varying(255),
    ip_address character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    via_application_id integer
);


--
-- Name: link_trackers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.link_trackers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: link_trackers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.link_trackers_id_seq OWNED BY public.link_trackers.id;


--
-- Name: mailjet_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mailjet_stats (
    id bigint NOT NULL,
    campaign_id character varying NOT NULL,
    campaign_name character varying NOT NULL,
    date date NOT NULL,
    event_click_delay integer DEFAULT 0 NOT NULL,
    event_clicked_count integer DEFAULT 0 NOT NULL,
    event_open_delay integer DEFAULT 0 NOT NULL,
    event_opened_count integer DEFAULT 0 NOT NULL,
    event_spam_count integer DEFAULT 0 NOT NULL,
    event_unsubscribed_count integer DEFAULT 0 NOT NULL,
    event_workflow_exited_count integer DEFAULT 0 NOT NULL,
    message_blocked_count integer DEFAULT 0 NOT NULL,
    message_clicked_count integer DEFAULT 0 NOT NULL,
    message_deferred_count integer DEFAULT 0 NOT NULL,
    message_hard_bounced_count integer DEFAULT 0 NOT NULL,
    message_opened_count integer DEFAULT 0 NOT NULL,
    message_queued_count integer DEFAULT 0 NOT NULL,
    message_sent_count integer DEFAULT 0 NOT NULL,
    message_soft_bounced_count integer DEFAULT 0 NOT NULL,
    message_spam_count integer DEFAULT 0 NOT NULL,
    message_unsubscribed_count integer DEFAULT 0 NOT NULL,
    message_work_flow_exited_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: mailjet_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mailjet_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailjet_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mailjet_stats_id_seq OWNED BY public.mailjet_stats.id;


--
-- Name: maker_activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maker_activities (
    id bigint NOT NULL,
    activity_type integer DEFAULT 0 NOT NULL,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    hidden_at timestamp without time zone,
    maker_group_id bigint NOT NULL
);


--
-- Name: maker_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maker_activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maker_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maker_activities_id_seq OWNED BY public.maker_activities.id;


--
-- Name: maker_fest_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maker_fest_participants (
    id integer NOT NULL,
    category_slug integer DEFAULT 0 NOT NULL,
    user_id integer NOT NULL,
    upcoming_page_id integer NOT NULL,
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    external_link character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: maker_fest_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maker_fest_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maker_fest_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maker_fest_participants_id_seq OWNED BY public.maker_fest_participants.id;


--
-- Name: maker_group_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maker_group_members (
    id integer NOT NULL,
    maker_group_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state integer DEFAULT 0 NOT NULL,
    role integer DEFAULT 0 NOT NULL,
    assessed_at timestamp without time zone,
    assessed_user_id integer,
    last_activity_at timestamp without time zone
);


--
-- Name: maker_group_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maker_group_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maker_group_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maker_group_members_id_seq OWNED BY public.maker_group_members.id;


--
-- Name: maker_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maker_groups (
    id integer NOT NULL,
    name character varying NOT NULL,
    kind integer DEFAULT 0 NOT NULL,
    completed_goals_count integer DEFAULT 0 NOT NULL,
    goals_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description character varying NOT NULL,
    members_count integer DEFAULT 0 NOT NULL,
    pending_members_count integer DEFAULT 0 NOT NULL,
    tagline character varying NOT NULL,
    last_activity_at timestamp without time zone,
    instructions_html text,
    discussions_count integer DEFAULT 0 NOT NULL
);


--
-- Name: maker_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maker_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maker_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maker_groups_id_seq OWNED BY public.maker_groups.id;


--
-- Name: maker_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maker_reports (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    activity_created_after timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    activity_created_before timestamp without time zone NOT NULL
);


--
-- Name: maker_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maker_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maker_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maker_reports_id_seq OWNED BY public.maker_reports.id;


--
-- Name: maker_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maker_suggestions (
    id integer NOT NULL,
    approved_by_id integer,
    invited_by_id integer,
    maker_id integer,
    post_id integer,
    product_maker_id integer,
    maker_username character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: maker_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maker_suggestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maker_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maker_suggestions_id_seq OWNED BY public.maker_suggestions.id;


--
-- Name: makers_festival_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.makers_festival_categories (
    id integer NOT NULL,
    emoji character varying NOT NULL,
    name character varying NOT NULL,
    tagline text NOT NULL,
    makers_festival_edition_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: makers_festival_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.makers_festival_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: makers_festival_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.makers_festival_categories_id_seq OWNED BY public.makers_festival_categories.id;


--
-- Name: makers_festival_editions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.makers_festival_editions (
    id integer NOT NULL,
    start_date date NOT NULL,
    sponsor character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discussions_count integer DEFAULT 0 NOT NULL,
    slug character varying,
    name character varying,
    tagline character varying,
    description text,
    prizes text,
    discussion_preview_uuid character varying,
    embed_url character varying,
    banner_uuid character varying,
    social_banner_uuid character varying,
    result_url character varying,
    registration timestamp without time zone,
    registration_ended timestamp without time zone,
    submission timestamp without time zone,
    submission_ended timestamp without time zone,
    voting timestamp without time zone,
    voting_ended timestamp without time zone,
    result timestamp without time zone,
    maker_group_id bigint,
    share_text text
);


--
-- Name: makers_festival_editions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.makers_festival_editions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: makers_festival_editions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.makers_festival_editions_id_seq OWNED BY public.makers_festival_editions.id;


--
-- Name: makers_festival_makers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.makers_festival_makers (
    id integer NOT NULL,
    user_id integer NOT NULL,
    makers_festival_participant_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: makers_festival_makers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.makers_festival_makers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: makers_festival_makers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.makers_festival_makers_id_seq OWNED BY public.makers_festival_makers.id;


--
-- Name: makers_festival_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.makers_festival_participants (
    id integer NOT NULL,
    user_id integer NOT NULL,
    makers_festival_category_id integer NOT NULL,
    external_link character varying,
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    project_details jsonb DEFAULT '{}'::jsonb NOT NULL,
    finalist boolean DEFAULT false NOT NULL,
    winner boolean DEFAULT false NOT NULL,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    receive_tc_resources boolean DEFAULT false NOT NULL
);


--
-- Name: makers_festival_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.makers_festival_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: makers_festival_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.makers_festival_participants_id_seq OWNED BY public.makers_festival_participants.id;


--
-- Name: marketing_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketing_notifications (
    id bigint NOT NULL,
    sender_id bigint NOT NULL,
    user_ids character varying NOT NULL,
    heading character varying NOT NULL,
    body character varying,
    one_liner character varying,
    deeplink character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: marketing_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marketing_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marketing_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.marketing_notifications_id_seq OWNED BY public.marketing_notifications.id;


--
-- Name: media; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media (
    id bigint NOT NULL,
    user_id bigint,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    uuid character varying NOT NULL,
    kind character varying NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    original_width integer NOT NULL,
    original_height integer NOT NULL,
    metadata json,
    original_url text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: media_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.media_id_seq OWNED BY public.media.id;


--
-- Name: mentions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mentions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    subject_type text NOT NULL,
    subject_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mentions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mentions_id_seq OWNED BY public.mentions.id;


--
-- Name: mobile_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mobile_devices (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    device_uuid character varying,
    os integer,
    os_version character varying,
    app_version character varying,
    push_notification_token character varying,
    one_signal_player_id character varying,
    last_active_at date NOT NULL,
    sign_out_at date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    device_model character varying,
    send_mention_push boolean DEFAULT true NOT NULL,
    send_new_follower_push boolean DEFAULT true NOT NULL,
    send_friend_post_push boolean DEFAULT true NOT NULL,
    send_comment_on_post_push boolean DEFAULT true NOT NULL,
    send_reply_on_comments_push boolean DEFAULT true NOT NULL,
    send_trending_posts_push boolean DEFAULT true NOT NULL,
    send_community_updates_push boolean DEFAULT true NOT NULL,
    send_product_request_push boolean DEFAULT true NOT NULL,
    send_missed_post_push boolean DEFAULT true NOT NULL,
    send_top_post_competition_push boolean DEFAULT true NOT NULL,
    send_product_mention_push boolean DEFAULT true NOT NULL,
    send_friend_product_maker_push boolean DEFAULT true NOT NULL,
    send_visit_streak_ending_push boolean DEFAULT true NOT NULL,
    send_vote_push boolean DEFAULT true NOT NULL
);


--
-- Name: mobile_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mobile_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mobile_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mobile_devices_id_seq OWNED BY public.mobile_devices.id;


--
-- Name: moderation_duplicate_post_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_duplicate_post_requests (
    id bigint NOT NULL,
    post_id bigint NOT NULL,
    url character varying NOT NULL,
    reason character varying NOT NULL,
    approved_at timestamp without time zone,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: moderation_duplicate_post_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.moderation_duplicate_post_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderation_duplicate_post_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.moderation_duplicate_post_requests_id_seq OWNED BY public.moderation_duplicate_post_requests.id;


--
-- Name: moderation_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_locks (
    id bigint NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: moderation_locks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.moderation_locks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderation_locks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.moderation_locks_id_seq OWNED BY public.moderation_locks.id;


--
-- Name: moderation_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_logs (
    id integer NOT NULL,
    reference_id integer NOT NULL,
    reference_type character varying NOT NULL,
    moderator_id integer NOT NULL,
    message text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reason text,
    share_public boolean DEFAULT false NOT NULL
);


--
-- Name: moderation_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.moderation_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderation_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.moderation_logs_id_seq OWNED BY public.moderation_logs.id;


--
-- Name: moderation_skips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.moderation_skips (
    id bigint NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    user_id bigint NOT NULL,
    message character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: moderation_skips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.moderation_skips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: moderation_skips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.moderation_skips_id_seq OWNED BY public.moderation_skips.id;


--
-- Name: multi_factor_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.multi_factor_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: multi_factor_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.multi_factor_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: multi_factor_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.multi_factor_tokens_id_seq OWNED BY public.multi_factor_tokens.id;


--
-- Name: newsletter_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletter_events (
    id integer NOT NULL,
    event_name character varying NOT NULL,
    "time" timestamp without time zone NOT NULL,
    subscriber_id integer,
    newsletter_id integer,
    link_url character varying,
    ip character varying,
    geo character varying,
    agent character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    newsletter_variant_id integer,
    link_section character varying
);


--
-- Name: newsletter_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletter_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletter_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletter_events_id_seq OWNED BY public.newsletter_events.id;


--
-- Name: newsletter_experiments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletter_experiments (
    id integer NOT NULL,
    newsletter_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    test_count integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: newsletter_experiments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletter_experiments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletter_experiments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletter_experiments_id_seq OWNED BY public.newsletter_experiments.id;


--
-- Name: newsletter_sponsors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletter_sponsors (
    id bigint NOT NULL,
    newsletter_id bigint NOT NULL,
    image_uuid character varying NOT NULL,
    link character varying NOT NULL,
    description_html text NOT NULL,
    body_image_uuid character varying,
    cta character varying
);


--
-- Name: newsletter_sponsors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletter_sponsors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletter_sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletter_sponsors_id_seq OWNED BY public.newsletter_sponsors.id;


--
-- Name: newsletter_variants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletter_variants (
    id integer NOT NULL,
    newsletter_experiment_id integer NOT NULL,
    variant_winner integer DEFAULT 0 NOT NULL,
    sections jsonb,
    subject character varying,
    status integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: newsletter_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletter_variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletter_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletter_variants_id_seq OWNED BY public.newsletter_variants.id;


--
-- Name: newsletters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newsletters (
    id integer NOT NULL,
    subject character varying NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    kind integer DEFAULT 0 NOT NULL,
    date date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sections jsonb DEFAULT '[]'::jsonb NOT NULL,
    posts jsonb DEFAULT '[]'::jsonb NOT NULL,
    preview_token character varying,
    sips integer[] DEFAULT '{}'::integer[],
    meetup_event jsonb,
    anthologies_story_id bigint,
    social_image_uuid character varying,
    skip_sponsor boolean DEFAULT false,
    sponsor_title character varying DEFAULT 'Sponsored By'::character varying
);


--
-- Name: newsletters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.newsletters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: newsletters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.newsletters_id_seq OWNED BY public.newsletters.id;


--
-- Name: notification_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_events (
    id integer NOT NULL,
    notification_id integer NOT NULL,
    channel_name character varying NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    failure_reason text,
    sent_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    interacted_at timestamp without time zone
);


--
-- Name: notification_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notification_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notification_events_id_seq OWNED BY public.notification_events.id;


--
-- Name: notification_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_logs (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    kind integer NOT NULL,
    notifyable_id integer NOT NULL,
    notifyable_type character varying NOT NULL,
    subscriber_id integer NOT NULL
);


--
-- Name: notification_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notification_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notification_logs_id_seq OWNED BY public.notification_logs.id;


--
-- Name: notification_push_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_push_logs (
    id bigint NOT NULL,
    uuid character varying NOT NULL,
    channel character varying NOT NULL,
    kind character varying NOT NULL,
    received boolean DEFAULT false,
    converted boolean DEFAULT false,
    url character varying,
    platform character varying NOT NULL,
    delivery_method character varying NOT NULL,
    sent_at timestamp without time zone NOT NULL,
    raw_response jsonb NOT NULL,
    user_id integer,
    notification_event_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notification_push_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notification_push_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_push_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notification_push_logs_id_seq OWNED BY public.notification_push_logs.id;


--
-- Name: notification_subscription_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_subscription_logs (
    id integer NOT NULL,
    subscriber_id integer NOT NULL,
    kind integer NOT NULL,
    channel_name character varying NOT NULL,
    setting_details character varying,
    source character varying NOT NULL,
    source_details character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notification_subscription_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notification_subscription_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_subscription_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notification_subscription_logs_id_seq OWNED BY public.notification_subscription_logs.id;


--
-- Name: notification_unsubscription_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_unsubscription_logs (
    id integer NOT NULL,
    subscriber_id integer NOT NULL,
    kind integer NOT NULL,
    channel_name character varying NOT NULL,
    notifyable_id integer,
    notifyable_type character varying,
    source integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source_details character varying
);


--
-- Name: notification_unsubscription_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notification_unsubscription_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_unsubscription_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notification_unsubscription_logs_id_seq OWNED BY public.notification_unsubscription_logs.id;


--
-- Name: notifications_subscribers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications_subscribers (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    browser_push_token character varying,
    mobile_push_token character varying,
    desktop_push_token character varying,
    options jsonb DEFAULT '{}'::jsonb NOT NULL,
    email_confirmed boolean DEFAULT false,
    email public.citext,
    verification_token character varying,
    verification_token_generated_at timestamp without time zone,
    grandfathered_verification boolean,
    first_time_newsletter_recipient boolean DEFAULT true
);


--
-- Name: notifications_subscribers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_subscribers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_subscribers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_subscribers_id_seq OWNED BY public.notifications_subscribers.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id integer NOT NULL,
    resource_owner_id integer NOT NULL,
    application_id integer NOT NULL,
    token character varying(255) NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying(255)
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id integer NOT NULL,
    resource_owner_id integer,
    application_id integer,
    token character varying(255) NOT NULL,
    refresh_token character varying(255),
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying(255)
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    uid character varying(255) NOT NULL,
    secret character varying(255) NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    twitter_app_name character varying(255),
    owner_id integer,
    owner_type character varying(255),
    twitter_auth_allowed boolean DEFAULT false,
    twitter_consumer_key character varying(255),
    twitter_consumer_secret character varying(255),
    write_access_allowed boolean DEFAULT false,
    max_requests_per_hour integer DEFAULT 3600 NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    max_points_per_hour integer DEFAULT 25000 NOT NULL,
    legacy boolean DEFAULT false NOT NULL
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: oauth_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_requests (
    id bigint NOT NULL,
    last_request_at timestamp without time zone NOT NULL,
    user_id bigint,
    application_id bigint NOT NULL
);


--
-- Name: oauth_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_requests_id_seq OWNED BY public.oauth_requests.id;


--
-- Name: onboarding_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.onboarding_reasons (
    id bigint NOT NULL,
    reason character varying NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: onboarding_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.onboarding_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: onboarding_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.onboarding_reasons_id_seq OWNED BY public.onboarding_reasons.id;


--
-- Name: onboarding_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.onboarding_tasks (
    id bigint NOT NULL,
    task character varying NOT NULL,
    user_id bigint NOT NULL,
    completed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: onboarding_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.onboarding_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: onboarding_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.onboarding_tasks_id_seq OWNED BY public.onboarding_tasks.id;


--
-- Name: onboardings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.onboardings (
    id integer NOT NULL,
    name integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    step integer
);


--
-- Name: onboardings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.onboardings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: onboardings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.onboardings_id_seq OWNED BY public.onboardings.id;


--
-- Name: page_contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_contents (
    id bigint NOT NULL,
    page_key character varying NOT NULL,
    element_key character varying NOT NULL,
    content text,
    image_uuid character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: page_contents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_contents_id_seq OWNED BY public.page_contents.id;


--
-- Name: payment_card_update_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_card_update_logs (
    id bigint NOT NULL,
    stripe_token_id character varying NOT NULL,
    stripe_customer_id character varying NOT NULL,
    project character varying NOT NULL,
    success boolean DEFAULT true NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: payment_card_update_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_card_update_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_card_update_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_card_update_logs_id_seq OWNED BY public.payment_card_update_logs.id;


--
-- Name: payment_discounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_discounts (
    id integer NOT NULL,
    active boolean DEFAULT false NOT NULL,
    percentage_off integer NOT NULL,
    name character varying NOT NULL,
    stripe_coupon_code character varying NOT NULL,
    code character varying NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    subscriptions_count integer DEFAULT 0 NOT NULL
);


--
-- Name: payment_discounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_discounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_discounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_discounts_id_seq OWNED BY public.payment_discounts.id;


--
-- Name: payment_plan_discount_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_plan_discount_associations (
    id integer NOT NULL,
    plan_id integer,
    discount_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: payment_plan_discount_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_plan_discount_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_plan_discount_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_plan_discount_associations_id_seq OWNED BY public.payment_plan_discount_associations.id;


--
-- Name: payment_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_plans (
    id integer NOT NULL,
    amount_in_cents integer NOT NULL,
    period_in_months integer NOT NULL,
    project integer NOT NULL,
    stripe_plan_id character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    subscriptions_count integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL
);


--
-- Name: payment_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_plans_id_seq OWNED BY public.payment_plans.id;


--
-- Name: payment_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_subscriptions (
    id integer NOT NULL,
    project integer NOT NULL,
    plan_amount_in_cents integer NOT NULL,
    stripe_customer_id character varying NOT NULL,
    stripe_subscription_id character varying NOT NULL,
    stripe_coupon_code character varying,
    cancellation_reason character varying,
    user_canceled_at timestamp without time zone,
    stripe_canceled_at timestamp without time zone,
    expired_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer NOT NULL,
    plan_id integer NOT NULL,
    discount_id integer,
    renew_notice_sent_at timestamp without time zone,
    stripe_refund_id character varying,
    refund_reason character varying,
    refunded_at timestamp without time zone,
    charged_amount_in_cents integer NOT NULL,
    marketing_campaign_name character varying
);


--
-- Name: payment_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_subscriptions_id_seq OWNED BY public.payment_subscriptions.id;


--
-- Name: pghero_query_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pghero_query_stats (
    id integer NOT NULL,
    database text,
    "user" text,
    query text,
    query_hash bigint,
    total_time double precision,
    calls bigint,
    captured_at timestamp without time zone
);


--
-- Name: pghero_query_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pghero_query_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pghero_query_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pghero_query_stats_id_seq OWNED BY public.pghero_query_stats.id;


--
-- Name: poll_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.poll_answers (
    id bigint NOT NULL,
    poll_option_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: poll_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.poll_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poll_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.poll_answers_id_seq OWNED BY public.poll_answers.id;


--
-- Name: poll_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.poll_options (
    id bigint NOT NULL,
    poll_id bigint NOT NULL,
    text character varying NOT NULL,
    image_uuid character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    answers_count integer DEFAULT 0 NOT NULL
);


--
-- Name: poll_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.poll_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: poll_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.poll_options_id_seq OWNED BY public.poll_options.id;


--
-- Name: polls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.polls (
    id bigint NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    options_count integer DEFAULT 0 NOT NULL,
    answers_count integer DEFAULT 0 NOT NULL
);


--
-- Name: polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.polls_id_seq OWNED BY public.polls.id;


--
-- Name: post_drafts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_drafts (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    post_id bigint,
    uuid character varying NOT NULL,
    url character varying NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    suggested_product_id bigint,
    connect_product boolean DEFAULT false NOT NULL
);


--
-- Name: post_drafts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_drafts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_drafts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_drafts_id_seq OWNED BY public.post_drafts.id;


--
-- Name: post_item_views_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_item_views_logs (
    id bigint NOT NULL,
    user_id integer,
    visitor_id character varying NOT NULL,
    seen_post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    seen_posts_count integer DEFAULT 0 NOT NULL,
    browser_width integer DEFAULT 0 NOT NULL,
    browser_height integer DEFAULT 0 NOT NULL,
    browser character varying,
    device character varying,
    platform character varying,
    country character varying,
    ip character varying,
    referer character varying,
    ab_test_variant character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_item_views_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_item_views_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_item_views_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_item_views_logs_id_seq OWNED BY public.post_item_views_logs.id;


--
-- Name: post_topic_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_topic_associations (
    id integer NOT NULL,
    post_id integer NOT NULL,
    topic_id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_topic_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_topic_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_topic_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_topic_associations_id_seq OWNED BY public.post_topic_associations.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id integer NOT NULL,
    user_id integer,
    name character varying(255),
    tagline character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    slug character varying(255),
    link_visits integer DEFAULT 0 NOT NULL,
    link_unique_visits integer DEFAULT 0 NOT NULL,
    score_multiplier double precision DEFAULT 1.0,
    promoted_at timestamp without time zone,
    accepted_duplicate boolean DEFAULT false,
    featured_at timestamp without time zone,
    trashed_at timestamp without time zone,
    product_id integer,
    comments_count integer DEFAULT 0 NOT NULL,
    reviews_count integer DEFAULT 0 NOT NULL,
    alternatives_count integer DEFAULT 0 NOT NULL,
    podcast boolean DEFAULT false NOT NULL,
    disabled_when_scheduled boolean DEFAULT true,
    scheduled_at timestamp without time zone NOT NULL,
    description_length integer DEFAULT 0 NOT NULL,
    description_html text,
    changes_in_version character varying,
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    user_edited_at timestamp without time zone,
    related_posts_count integer DEFAULT 0 NOT NULL,
    user_flags_count integer DEFAULT 0,
    promo_code character varying,
    promo_text character varying,
    promo_expire_at timestamp without time zone,
    pricing_type character varying,
    reviews_with_body_count integer DEFAULT 0 NOT NULL,
    thumbnail_image_uuid character varying,
    social_media_image_uuid character varying,
    share_with_press boolean DEFAULT false NOT NULL,
    reviews_with_rating_count integer DEFAULT 0 NOT NULL,
    reviews_rating numeric(3,2) DEFAULT 0.0 NOT NULL,
    product_state integer DEFAULT 0 NOT NULL,
    exclude_from_ranking boolean DEFAULT false NOT NULL,
    daily_rank integer,
    weekly_rank integer,
    monthly_rank integer,
    makers_count integer DEFAULT 0 NOT NULL
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: posts_launch_day_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts_launch_day_reports (
    id bigint NOT NULL,
    post_id bigint NOT NULL,
    s3_key character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: posts_launch_day_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_launch_day_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_launch_day_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_launch_day_reports_id_seq OWNED BY public.posts_launch_day_reports.id;


--
-- Name: product_activity_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_activity_events (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    occurred_at timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    votes_count integer DEFAULT 0 NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    nominations_count integer DEFAULT 0 NOT NULL,
    title character varying
);


--
-- Name: product_activity_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_activity_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_activity_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_activity_events_id_seq OWNED BY public.product_activity_events.id;


--
-- Name: product_alternative_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_alternative_suggestions (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    alternative_product_id bigint NOT NULL,
    user_id bigint,
    source character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: product_alternative_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_alternative_suggestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_alternative_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_alternative_suggestions_id_seq OWNED BY public.product_alternative_suggestions.id;


--
-- Name: product_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_associations (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    associated_product_id bigint NOT NULL,
    relationship character varying NOT NULL,
    source character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL
);


--
-- Name: product_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_associations_id_seq OWNED BY public.product_associations.id;


--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_categories (
    id bigint NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    description character varying,
    parent_id bigint,
    products_count integer DEFAULT 0 NOT NULL,
    children_categories_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: product_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_categories_id_seq OWNED BY public.product_categories.id;


--
-- Name: product_category_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_category_associations (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    category_id bigint NOT NULL,
    source character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: product_category_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_category_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_category_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_category_associations_id_seq OWNED BY public.product_category_associations.id;


--
-- Name: product_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_links (
    id bigint NOT NULL,
    url character varying NOT NULL,
    source character varying NOT NULL,
    url_kind character varying NOT NULL,
    clicks_count integer DEFAULT 0 NOT NULL,
    product_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: product_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_links_id_seq OWNED BY public.product_links.id;


--
-- Name: product_makers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_makers (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: product_makers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_makers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_makers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_makers_id_seq OWNED BY public.product_makers.id;


--
-- Name: product_post_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_post_associations (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    post_id bigint NOT NULL,
    kind character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source character varying NOT NULL
);


--
-- Name: product_post_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_post_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_post_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_post_associations_id_seq OWNED BY public.product_post_associations.id;


--
-- Name: product_request_related_product_request_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_request_related_product_request_associations (
    id integer NOT NULL,
    product_request_id integer NOT NULL,
    related_product_request_id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: product_request_related_product_request_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_request_related_product_request_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_request_related_product_request_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_request_related_product_request_associations_id_seq OWNED BY public.product_request_related_product_request_associations.id;


--
-- Name: product_request_topic_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_request_topic_associations (
    id integer NOT NULL,
    product_request_id integer NOT NULL,
    topic_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: product_request_topic_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_request_topic_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_request_topic_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_request_topic_associations_id_seq OWNED BY public.product_request_topic_associations.id;


--
-- Name: product_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_requests (
    id integer NOT NULL,
    user_id integer NOT NULL,
    title text NOT NULL,
    body text,
    recommended_products_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    followers_count integer DEFAULT 0 NOT NULL,
    edited_at timestamp without time zone,
    hidden_at timestamp without time zone,
    comments_count integer DEFAULT 0 NOT NULL,
    duplicate_of_id integer,
    seo_title text,
    seo_description text,
    featured_at timestamp without time zone,
    related_product_requests_count integer DEFAULT 0 NOT NULL,
    anonymous boolean DEFAULT false,
    kind integer NOT NULL,
    user_flags_count integer DEFAULT 0
);


--
-- Name: product_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_requests_id_seq OWNED BY public.product_requests.id;


--
-- Name: product_review_summaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_review_summaries (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    reviewers_count integer DEFAULT 0 NOT NULL,
    reviews_count integer DEFAULT 0 NOT NULL,
    rating numeric(3,2) DEFAULT 0.0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: product_review_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_review_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_review_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_review_summaries_id_seq OWNED BY public.product_review_summaries.id;


--
-- Name: product_review_summary_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_review_summary_associations (
    id bigint NOT NULL,
    product_review_summary_id bigint NOT NULL,
    review_id bigint NOT NULL
);


--
-- Name: product_review_summary_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_review_summary_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_review_summary_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_review_summary_associations_id_seq OWNED BY public.product_review_summary_associations.id;


--
-- Name: product_scrape_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_scrape_results (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    url character varying,
    source character varying NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: product_scrape_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_scrape_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_scrape_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_scrape_results_id_seq OWNED BY public.product_scrape_results.id;


--
-- Name: product_screenshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_screenshots (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    user_id bigint,
    image_uuid character varying NOT NULL,
    alt_text character varying,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: product_screenshots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_screenshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_screenshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_screenshots_id_seq OWNED BY public.product_screenshots.id;


--
-- Name: product_stacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_stacks (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    user_id bigint NOT NULL,
    source character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: product_stacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_stacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_stacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_stacks_id_seq OWNED BY public.product_stacks.id;


--
-- Name: product_topic_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_topic_associations (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    topic_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: product_topic_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_topic_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_topic_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_topic_associations_id_seq OWNED BY public.product_topic_associations.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    clean_url character varying,
    website_url character varying,
    tagline character varying NOT NULL,
    description text,
    slug character varying NOT NULL,
    name character varying NOT NULL,
    reviewed boolean DEFAULT false NOT NULL,
    source character varying NOT NULL,
    media_count integer DEFAULT 0 NOT NULL,
    posts_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    categories_count integer DEFAULT 0 NOT NULL,
    topics_count integer DEFAULT 0 NOT NULL,
    followers_count integer DEFAULT 0 NOT NULL,
    visible boolean DEFAULT true NOT NULL,
    logo_uuid character varying,
    reviews_count integer DEFAULT 0 NOT NULL,
    reviews_with_body_count integer DEFAULT 0 NOT NULL,
    reviews_with_rating_count integer DEFAULT 0 NOT NULL,
    reviews_rating numeric(3,2) DEFAULT 0.0 NOT NULL,
    jobs_count integer DEFAULT 0 NOT NULL,
    alternatives_count integer DEFAULT 0 NOT NULL,
    twitter_url character varying,
    instagram_url character varying,
    github_url character varying,
    facebook_url character varying,
    medium_url character varying,
    angellist_url character varying,
    addons_count integer DEFAULT 0 NOT NULL,
    sort_key_max_votes integer DEFAULT 0 NOT NULL,
    total_votes_count integer DEFAULT 0 NOT NULL,
    related_products_count integer DEFAULT 0 NOT NULL,
    latest_post_at timestamp without time zone,
    state character varying DEFAULT 'live'::character varying NOT NULL,
    earliest_post_at timestamp without time zone,
    user_flags_count integer DEFAULT 0 NOT NULL,
    trashed_at timestamp without time zone,
    stacks_count integer DEFAULT 0
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: products_skip_review_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products_skip_review_suggestions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    product_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: products_skip_review_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_skip_review_suggestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_skip_review_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_skip_review_suggestions_id_seq OWNED BY public.products_skip_review_suggestions.id;


--
-- Name: promoted_analytics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promoted_analytics (
    id integer NOT NULL,
    user_id integer,
    promoted_product_id integer,
    ip_address character varying,
    track_code character varying,
    source character varying,
    user_action character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    nonce character varying,
    user_agent character varying
);


--
-- Name: promoted_analytics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promoted_analytics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promoted_analytics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promoted_analytics_id_seq OWNED BY public.promoted_analytics.id;


--
-- Name: promoted_email_ab_test_variants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promoted_email_ab_test_variants (
    id bigint NOT NULL,
    title character varying,
    tagline character varying,
    thumbnail_uuid character varying,
    promoted_email_ab_test_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cta_text character varying
);


--
-- Name: promoted_email_ab_test_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promoted_email_ab_test_variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promoted_email_ab_test_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promoted_email_ab_test_variants_id_seq OWNED BY public.promoted_email_ab_test_variants.id;


--
-- Name: promoted_email_ab_tests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promoted_email_ab_tests (
    id bigint NOT NULL,
    test_running boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promoted_email_ab_tests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promoted_email_ab_tests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promoted_email_ab_tests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promoted_email_ab_tests_id_seq OWNED BY public.promoted_email_ab_tests.id;


--
-- Name: promoted_email_campaign_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promoted_email_campaign_configs (
    id bigint NOT NULL,
    campaign_name character varying NOT NULL,
    signups_cap integer DEFAULT '-1'::integer NOT NULL,
    signups_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promoted_email_campaign_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promoted_email_campaign_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promoted_email_campaign_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promoted_email_campaign_configs_id_seq OWNED BY public.promoted_email_campaign_configs.id;


--
-- Name: promoted_email_campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promoted_email_campaigns (
    id bigint NOT NULL,
    title character varying NOT NULL,
    tagline character varying NOT NULL,
    thumbnail_uuid character varying NOT NULL,
    promoted_type integer DEFAULT 1 NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    webhook_enabled boolean DEFAULT false NOT NULL,
    webhook_url character varying,
    webhook_auth_header character varying,
    webhook_payload character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    campaign_name character varying,
    promoted_email_ab_test_id bigint,
    signups_count integer DEFAULT 0 NOT NULL,
    cta_text character varying
);


--
-- Name: promoted_email_campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promoted_email_campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promoted_email_campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promoted_email_campaigns_id_seq OWNED BY public.promoted_email_campaigns.id;


--
-- Name: promoted_email_signups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promoted_email_signups (
    id bigint NOT NULL,
    email character varying NOT NULL,
    promoted_email_campaign_id bigint NOT NULL,
    user_id bigint,
    ip_address character varying,
    track_code character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promoted_email_signups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promoted_email_signups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promoted_email_signups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promoted_email_signups_id_seq OWNED BY public.promoted_email_signups.id;


--
-- Name: promoted_product_campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promoted_product_campaigns (
    id bigint NOT NULL,
    name character varying NOT NULL,
    impressions_cap integer DEFAULT '-1'::integer NOT NULL,
    impressions_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: promoted_product_campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promoted_product_campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promoted_product_campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promoted_product_campaigns_id_seq OWNED BY public.promoted_product_campaigns.id;


--
-- Name: promoted_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.promoted_products (
    id integer NOT NULL,
    promoted_at timestamp without time zone,
    post_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    link_visits integer DEFAULT 0 NOT NULL,
    link_unique_visits integer DEFAULT 0 NOT NULL,
    close_count integer DEFAULT 0 NOT NULL,
    home_utms text,
    newsletter_utms text,
    newsletter_id integer,
    newsletter_title character varying,
    newsletter_description text,
    newsletter_link text,
    newsletter_image_uuid character varying,
    deal character varying,
    open_as_post_page boolean DEFAULT false,
    promoted_type integer DEFAULT 0 NOT NULL,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    topic_bundle character varying,
    analytics_test boolean DEFAULT false,
    trashed_at timestamp without time zone,
    url character varying,
    name character varying,
    tagline character varying,
    thumbnail_uuid character varying,
    promoted_product_campaign_id bigint,
    cta_text character varying,
    impressions_count integer DEFAULT 0
);


--
-- Name: promoted_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.promoted_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: promoted_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.promoted_products_id_seq OWNED BY public.promoted_products.id;


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.questions (
    id bigint NOT NULL,
    post_id bigint NOT NULL,
    slug character varying NOT NULL,
    title character varying NOT NULL,
    answer text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.questions_id_seq OWNED BY public.questions.id;


--
-- Name: radio_sponsors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.radio_sponsors (
    id bigint NOT NULL,
    name character varying NOT NULL,
    link character varying NOT NULL,
    image_uuid character varying NOT NULL,
    start_datetime timestamp without time zone NOT NULL,
    end_datetime timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    image_width integer,
    image_height integer,
    image_thumbnail_width integer,
    image_thumbnail_height integer,
    image_class_name character varying
);


--
-- Name: radio_sponsors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.radio_sponsors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: radio_sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.radio_sponsors_id_seq OWNED BY public.radio_sponsors.id;


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommendations (
    id integer NOT NULL,
    recommended_product_id integer NOT NULL,
    user_id integer NOT NULL,
    body text NOT NULL,
    votes_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    edited_at timestamp without time zone,
    comments_count integer DEFAULT 0 NOT NULL,
    disclosed boolean DEFAULT false,
    highlighted boolean DEFAULT false,
    user_flags_count integer DEFAULT 0
);


--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recommendations_id_seq OWNED BY public.recommendations.id;


--
-- Name: recommended_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommended_products (
    id integer NOT NULL,
    product_request_id integer NOT NULL,
    name text,
    votes_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    score_multiplier double precision DEFAULT 1.0,
    new_product_id bigint NOT NULL
);


--
-- Name: recommended_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommended_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommended_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recommended_products_id_seq OWNED BY public.recommended_products.id;


--
-- Name: review_tag_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_tag_associations (
    id bigint NOT NULL,
    review_id bigint NOT NULL,
    review_tag_id bigint NOT NULL,
    sentiment integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: review_tag_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.review_tag_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: review_tag_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.review_tag_associations_id_seq OWNED BY public.review_tag_associations.id;


--
-- Name: review_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_tags (
    id bigint NOT NULL,
    property character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    positive_label character varying,
    negative_label character varying
);


--
-- Name: review_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.review_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: review_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.review_tags_id_seq OWNED BY public.review_tags.id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id integer NOT NULL,
    user_id integer NOT NULL,
    sentiment integer,
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    score_multiplier double precision DEFAULT 1.0 NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    usage_duration integer,
    comments_count integer DEFAULT 0 NOT NULL,
    pros_html text,
    cons_html text,
    body_html text,
    hidden_at timestamp without time zone,
    comment_id bigint,
    rating integer,
    overall_experience character varying,
    currently_using integer,
    product_id bigint,
    version integer DEFAULT 2 NOT NULL,
    user_flags_count integer DEFAULT 0 NOT NULL,
    post_id bigint
);


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: search_user_searches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.search_user_searches (
    id bigint NOT NULL,
    user_id bigint,
    search_type character varying NOT NULL,
    query character varying NOT NULL,
    normalized_query character varying(255) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    platform character varying DEFAULT 'web'::character varying NOT NULL
);


--
-- Name: search_user_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.search_user_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_user_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.search_user_searches_id_seq OWNED BY public.search_user_searches.id;


--
-- Name: seo_queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seo_queries (
    id integer NOT NULL,
    subject_type character varying NOT NULL,
    subject_id integer NOT NULL,
    query character varying NOT NULL,
    ctr double precision DEFAULT 0.0,
    "position" double precision DEFAULT 0.0,
    clicks integer DEFAULT 0,
    impressions integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: seo_queries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seo_queries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seo_queries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seo_queries_id_seq OWNED BY public.seo_queries.id;


--
-- Name: seo_structured_data_validation_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seo_structured_data_validation_messages (
    id integer NOT NULL,
    subject_type character varying NOT NULL,
    subject_id integer NOT NULL,
    messages character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: seo_structured_data_validation_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seo_structured_data_validation_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seo_structured_data_validation_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seo_structured_data_validation_messages_id_seq OWNED BY public.seo_structured_data_validation_messages.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id integer NOT NULL,
    name character varying(255),
    value text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: ship_account_member_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_account_member_associations (
    id integer NOT NULL,
    ship_account_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ship_account_member_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_account_member_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_account_member_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_account_member_associations_id_seq OWNED BY public.ship_account_member_associations.id;


--
-- Name: ship_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_accounts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    ship_subscription_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contacts_count integer DEFAULT 0 NOT NULL,
    contacts_from_subscription_count integer DEFAULT 0 NOT NULL,
    contacts_from_message_reply_count integer DEFAULT 0 NOT NULL,
    contacts_from_import_count integer DEFAULT 0 NOT NULL,
    name character varying,
    data_processor_agreement integer DEFAULT 0 NOT NULL
);


--
-- Name: ship_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_accounts_id_seq OWNED BY public.ship_accounts.id;


--
-- Name: ship_aws_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_aws_applications (
    id integer NOT NULL,
    startup_name character varying NOT NULL,
    startup_email character varying NOT NULL,
    ship_account_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ship_aws_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_aws_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_aws_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_aws_applications_id_seq OWNED BY public.ship_aws_applications.id;


--
-- Name: ship_billing_informations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_billing_informations (
    id integer NOT NULL,
    stripe_customer_id character varying NOT NULL,
    stripe_token_id character varying,
    billing_email character varying,
    user_id integer NOT NULL,
    ship_invite_code_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ship_billing_informations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_billing_informations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_billing_informations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_billing_informations_id_seq OWNED BY public.ship_billing_informations.id;


--
-- Name: ship_cancellation_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_cancellation_reasons (
    id integer NOT NULL,
    reason text NOT NULL,
    billing_plan integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ship_cancellation_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_cancellation_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_cancellation_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_cancellation_reasons_id_seq OWNED BY public.ship_cancellation_reasons.id;


--
-- Name: ship_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_contacts (
    id integer NOT NULL,
    ship_account_id integer NOT NULL,
    user_id integer,
    clearbit_person_profile_id integer,
    email character varying NOT NULL,
    email_confirmed boolean DEFAULT false NOT NULL,
    token character varying NOT NULL,
    origin integer DEFAULT 0 NOT NULL,
    device_type integer,
    os character varying,
    user_agent character varying,
    ip_address character varying,
    unsubscribed_at timestamp without time zone,
    trashed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ship_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_contacts_id_seq OWNED BY public.ship_contacts.id;


--
-- Name: ship_instant_access_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_instant_access_pages (
    id integer NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    text text,
    ship_invite_code_id integer,
    trashed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    billing_periods integer DEFAULT 0
);


--
-- Name: ship_instant_access_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_instant_access_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_instant_access_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_instant_access_pages_id_seq OWNED BY public.ship_instant_access_pages.id;


--
-- Name: ship_invite_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_invite_codes (
    id integer NOT NULL,
    discount_value integer DEFAULT 0 NOT NULL,
    code character varying NOT NULL,
    image_uuid character varying,
    description text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ship_invite_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_invite_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_invite_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_invite_codes_id_seq OWNED BY public.ship_invite_codes.id;


--
-- Name: ship_leads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_leads (
    id integer NOT NULL,
    email character varying NOT NULL,
    name character varying,
    status integer DEFAULT 0 NOT NULL,
    project_name character varying,
    project_tagline character varying,
    project_phase integer DEFAULT 0 NOT NULL,
    launch_period integer DEFAULT 0 NOT NULL,
    user_id integer,
    ship_instant_access_page_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    team_size integer DEFAULT 0 NOT NULL,
    signup_goal character varying,
    incorporated boolean DEFAULT false,
    request_stripe_atlas boolean DEFAULT false,
    signup_design character varying
);


--
-- Name: ship_leads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_leads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_leads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_leads_id_seq OWNED BY public.ship_leads.id;


--
-- Name: ship_payment_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_payment_reports (
    id integer NOT NULL,
    net_revenue integer NOT NULL,
    date timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ship_payment_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_payment_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_payment_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_payment_reports_id_seq OWNED BY public.ship_payment_reports.id;


--
-- Name: ship_stripe_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_stripe_applications (
    id integer NOT NULL,
    ship_account_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ship_stripe_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_stripe_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_stripe_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_stripe_applications_id_seq OWNED BY public.ship_stripe_applications.id;


--
-- Name: ship_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_subscriptions (
    id integer NOT NULL,
    status integer NOT NULL,
    billing_plan integer NOT NULL,
    billing_period integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    stripe_subscription_id character varying,
    ends_at timestamp without time zone,
    cancelled_at timestamp without time zone,
    trial_ends_at timestamp without time zone
);


--
-- Name: ship_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_subscriptions_id_seq OWNED BY public.ship_subscriptions.id;


--
-- Name: ship_tracking_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_tracking_events (
    id integer NOT NULL,
    ship_tracking_identity_id integer NOT NULL,
    funnel_step character varying NOT NULL,
    event_name character varying NOT NULL,
    meta jsonb DEFAULT '"{}"'::jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ship_tracking_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_tracking_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_tracking_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_tracking_events_id_seq OWNED BY public.ship_tracking_events.id;


--
-- Name: ship_tracking_identities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_tracking_identities (
    id integer NOT NULL,
    visitor_id character varying,
    user_id integer,
    source character varying,
    campaign character varying,
    medium character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    landing_page character varying
);


--
-- Name: ship_tracking_identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_tracking_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_tracking_identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_tracking_identities_id_seq OWNED BY public.ship_tracking_identities.id;


--
-- Name: ship_user_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ship_user_metadata (
    id integer NOT NULL,
    ship_instant_access_page_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    initial_role integer,
    trial_used boolean DEFAULT false NOT NULL
);


--
-- Name: ship_user_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ship_user_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ship_user_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ship_user_metadata_id_seq OWNED BY public.ship_user_metadata.id;


--
-- Name: shoutouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shoutouts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    body text NOT NULL,
    trashed_at timestamp without time zone,
    votes_count integer DEFAULT 0 NOT NULL,
    credible_votes_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    priority integer DEFAULT 0 NOT NULL
);


--
-- Name: shoutouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shoutouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shoutouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shoutouts_id_seq OWNED BY public.shoutouts.id;


--
-- Name: similar_collection_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.similar_collection_associations (
    id integer NOT NULL,
    collection_id integer NOT NULL,
    similar_collection_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: similar_collection_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.similar_collection_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: similar_collection_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.similar_collection_associations_id_seq OWNED BY public.similar_collection_associations.id;


--
-- Name: spam_action_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spam_action_logs (
    id bigint NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    user_id bigint NOT NULL,
    spam boolean NOT NULL,
    false_positive boolean DEFAULT false NOT NULL,
    action_taken_on_activity character varying,
    action_taken_on_actor character varying,
    spam_ruleset_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reverted_at timestamp without time zone,
    reverted_by_id bigint
);


--
-- Name: spam_action_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spam_action_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spam_action_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spam_action_logs_id_seq OWNED BY public.spam_action_logs.id;


--
-- Name: spam_filter_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spam_filter_values (
    id bigint NOT NULL,
    filter_kind integer NOT NULL,
    value character varying NOT NULL,
    false_positive_count integer DEFAULT 0 NOT NULL,
    note text,
    added_by_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: spam_filter_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spam_filter_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spam_filter_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spam_filter_values_id_seq OWNED BY public.spam_filter_values.id;


--
-- Name: spam_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spam_logs (
    id bigint NOT NULL,
    content text NOT NULL,
    more_information jsonb DEFAULT '{}'::jsonb NOT NULL,
    user_id bigint,
    kind integer NOT NULL,
    content_type integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    remarks character varying NOT NULL,
    level integer NOT NULL,
    parent_log_id integer,
    action integer NOT NULL,
    false_positive boolean DEFAULT false NOT NULL
);


--
-- Name: spam_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spam_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spam_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spam_logs_id_seq OWNED BY public.spam_logs.id;


--
-- Name: spam_manual_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spam_manual_logs (
    id bigint NOT NULL,
    action integer NOT NULL,
    user_id bigint NOT NULL,
    activity_type character varying,
    activity_id bigint,
    reason text,
    handled_by_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reverted_by_id bigint,
    revert_reason character varying
);


--
-- Name: spam_manual_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spam_manual_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spam_manual_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spam_manual_logs_id_seq OWNED BY public.spam_manual_logs.id;


--
-- Name: spam_multiple_accounts_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spam_multiple_accounts_logs (
    id bigint NOT NULL,
    previous_user_id bigint NOT NULL,
    current_user_id bigint NOT NULL,
    request_info jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: spam_multiple_accounts_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spam_multiple_accounts_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spam_multiple_accounts_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spam_multiple_accounts_logs_id_seq OWNED BY public.spam_multiple_accounts_logs.id;


--
-- Name: spam_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spam_reports (
    id bigint NOT NULL,
    spam_action_log_id bigint NOT NULL,
    user_id bigint NOT NULL,
    "check" integer NOT NULL,
    action_taken integer,
    handled_by_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: spam_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spam_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spam_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spam_reports_id_seq OWNED BY public.spam_reports.id;


--
-- Name: spam_rule_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spam_rule_logs (
    id bigint NOT NULL,
    spam_ruleset_id bigint NOT NULL,
    spam_action_log_id bigint NOT NULL,
    spam_rule_id bigint NOT NULL,
    checked_data jsonb NOT NULL,
    spam_filter_value_id bigint,
    custom_value character varying,
    false_positive boolean DEFAULT false NOT NULL,
    spam boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: spam_rule_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spam_rule_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spam_rule_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spam_rule_logs_id_seq OWNED BY public.spam_rule_logs.id;


--
-- Name: spam_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spam_rules (
    id bigint NOT NULL,
    filter_kind integer NOT NULL,
    checks_count integer DEFAULT 0 NOT NULL,
    false_positive_count integer DEFAULT 0 NOT NULL,
    value character varying,
    spam_ruleset_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: spam_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spam_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spam_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spam_rules_id_seq OWNED BY public.spam_rules.id;


--
-- Name: spam_rulesets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spam_rulesets (
    id bigint NOT NULL,
    name character varying NOT NULL,
    note text,
    added_by_id bigint,
    active boolean DEFAULT true NOT NULL,
    for_activity integer NOT NULL,
    action_on_activity integer NOT NULL,
    action_on_actor integer NOT NULL,
    checks_count integer DEFAULT 0 NOT NULL,
    false_positive_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    ignore_not_spam_log boolean DEFAULT false NOT NULL,
    priority integer DEFAULT 0 NOT NULL
);


--
-- Name: spam_rulesets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spam_rulesets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spam_rulesets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spam_rulesets_id_seq OWNED BY public.spam_rulesets.id;


--
-- Name: stream_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stream_events (
    id bigint NOT NULL,
    source integer DEFAULT 0 NOT NULL,
    name character varying NOT NULL,
    source_path character varying,
    source_component character varying,
    subject_type character varying,
    subject_id bigint,
    user_id bigint,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    received_at timestamp without time zone NOT NULL
);


--
-- Name: stream_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stream_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stream_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stream_events_id_seq OWNED BY public.stream_events.id;


--
-- Name: stream_feed_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stream_feed_items (
    id bigint NOT NULL,
    verb character varying NOT NULL,
    actor_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    action_objects character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    receiver_id bigint NOT NULL,
    target_type character varying NOT NULL,
    target_id bigint NOT NULL,
    seen_at timestamp without time zone,
    last_occurrence_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data jsonb,
    connecting_text character varying NOT NULL,
    interactions jsonb
);


--
-- Name: stream_feed_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stream_feed_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stream_feed_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stream_feed_items_id_seq OWNED BY public.stream_feed_items.id;


--
-- Name: subject_media_modifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subject_media_modifications (
    id bigint NOT NULL,
    subject_type character varying,
    subject_id integer,
    subject_column character varying,
    original_image_uuid character varying,
    modified_image_uuid character varying,
    modified boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: subject_media_modifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subject_media_modifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subject_media_modifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subject_media_modifications_id_seq OWNED BY public.subject_media_modifications.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id integer NOT NULL,
    subscriber_id integer NOT NULL,
    subject_id integer,
    subject_type character varying,
    state integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source character varying,
    muted boolean DEFAULT false NOT NULL
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscriptions_id_seq OWNED BY public.subscriptions.id;


--
-- Name: team_invites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_invites (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    referrer_id bigint,
    identity_type character varying NOT NULL,
    email character varying,
    user_id bigint,
    code character varying NOT NULL,
    code_expires_at timestamp without time zone NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    status_changed_at timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_flags_count integer DEFAULT 0 NOT NULL
);


--
-- Name: team_invites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_invites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_invites_id_seq OWNED BY public.team_invites.id;


--
-- Name: team_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_members (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    product_id bigint NOT NULL,
    referrer_type character varying NOT NULL,
    referrer_id bigint NOT NULL,
    role character varying NOT NULL,
    "position" character varying,
    team_email character varying,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    status_changed_at timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: team_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_members_id_seq OWNED BY public.team_members.id;


--
-- Name: team_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_requests (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    product_id bigint NOT NULL,
    status_changed_by_id bigint,
    team_email character varying,
    approval_type character varying,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    status_changed_at timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    team_email_confirmed boolean DEFAULT false NOT NULL,
    verification_token character varying,
    verification_token_generated_at timestamp without time zone,
    additional_info text,
    user_flags_count integer DEFAULT 0,
    moderation_notes text
);


--
-- Name: team_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_requests_id_seq OWNED BY public.team_requests.id;


--
-- Name: topic_aliases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topic_aliases (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: topic_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.topic_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topic_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.topic_aliases_id_seq OWNED BY public.topic_aliases.id;


--
-- Name: topic_user_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topic_user_associations (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: topic_user_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.topic_user_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topic_user_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.topic_user_associations_id_seq OWNED BY public.topic_user_associations.id;


--
-- Name: topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.topics (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying DEFAULT ''::character varying NOT NULL,
    slug character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    posts_count integer DEFAULT 0 NOT NULL,
    image_uuid character varying,
    followers_count integer DEFAULT 0 NOT NULL,
    post_ids_minhash_signature public.hstore,
    subscribers_count integer DEFAULT 0 NOT NULL,
    stories_count integer DEFAULT 0 NOT NULL,
    emoji character varying,
    kind integer,
    parent_id bigint
);


--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.topics_id_seq OWNED BY public.topics.id;


--
-- Name: tracking_pixel_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tracking_pixel_logs (
    id bigint NOT NULL,
    kind integer NOT NULL,
    host character varying NOT NULL,
    url character varying NOT NULL,
    last_seen_at timestamp without time zone NOT NULL,
    embeddable_type character varying NOT NULL,
    embeddable_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tracking_pixel_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tracking_pixel_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tracking_pixel_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tracking_pixel_logs_id_seq OWNED BY public.tracking_pixel_logs.id;


--
-- Name: twitter_follower_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.twitter_follower_counts (
    id bigint NOT NULL,
    subject_id integer NOT NULL,
    subject_type character varying NOT NULL,
    follower_count integer DEFAULT 0 NOT NULL,
    last_checked timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: twitter_follower_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.twitter_follower_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: twitter_follower_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.twitter_follower_counts_id_seq OWNED BY public.twitter_follower_counts.id;


--
-- Name: twitter_verified_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.twitter_verified_users (
    id integer NOT NULL,
    twitter_uid text,
    twitter_username text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: twitter_verified_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.twitter_verified_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: twitter_verified_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.twitter_verified_users_id_seq OWNED BY public.twitter_verified_users.id;


--
-- Name: upcoming_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_events (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    post_id bigint,
    user_id bigint NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL,
    banner_uuid character varying NOT NULL,
    confirmed_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    rejected_at timestamp without time zone,
    active boolean DEFAULT false NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    user_edited_at timestamp without time zone,
    banner_mobile_uuid character varying
);


--
-- Name: upcoming_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_events_id_seq OWNED BY public.upcoming_events.id;


--
-- Name: upcoming_page_conversation_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_conversation_messages (
    id integer NOT NULL,
    body text NOT NULL,
    upcoming_page_conversation_id integer NOT NULL,
    upcoming_page_email_reply_id integer,
    upcoming_page_subscriber_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upcoming_page_conversation_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_conversation_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_conversation_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_conversation_messages_id_seq OWNED BY public.upcoming_page_conversation_messages.id;


--
-- Name: upcoming_page_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_conversations (
    id integer NOT NULL,
    upcoming_page_message_id integer NOT NULL,
    upcoming_page_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    seen_at timestamp without time zone,
    last_message_sent_at timestamp without time zone,
    trashed_at timestamp without time zone
);


--
-- Name: upcoming_page_conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_conversations_id_seq OWNED BY public.upcoming_page_conversations.id;


--
-- Name: upcoming_page_email_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_email_imports (
    id integer NOT NULL,
    state integer DEFAULT 0 NOT NULL,
    payload_csv bytea,
    upcoming_page_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    emails_count integer DEFAULT 0,
    upcoming_page_segment_id integer,
    failed_count integer DEFAULT 0 NOT NULL,
    imported_count integer DEFAULT 0 NOT NULL,
    duplicated_count integer DEFAULT 0 NOT NULL
);


--
-- Name: upcoming_page_email_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_email_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_email_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_email_imports_id_seq OWNED BY public.upcoming_page_email_imports.id;


--
-- Name: upcoming_page_email_replies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_email_replies (
    id integer NOT NULL,
    payload jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upcoming_page_email_replies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_email_replies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_email_replies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_email_replies_id_seq OWNED BY public.upcoming_page_email_replies.id;


--
-- Name: upcoming_page_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_links (
    id integer NOT NULL,
    upcoming_page_id integer NOT NULL,
    url character varying NOT NULL,
    kind character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upcoming_page_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_links_id_seq OWNED BY public.upcoming_page_links.id;


--
-- Name: upcoming_page_maker_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_maker_tasks (
    id integer NOT NULL,
    kind character varying NOT NULL,
    upcoming_page_id integer NOT NULL,
    completed_at timestamp without time zone,
    completed_by_user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upcoming_page_maker_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_maker_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_maker_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_maker_tasks_id_seq OWNED BY public.upcoming_page_maker_tasks.id;


--
-- Name: upcoming_page_message_deliveries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_message_deliveries (
    id integer NOT NULL,
    upcoming_page_message_id integer,
    upcoming_page_subscriber_id integer NOT NULL,
    sent_at timestamp without time zone,
    opened_at timestamp without time zone,
    clicked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    failed_at timestamp without time zone,
    subject_id integer,
    subject_type character varying
);


--
-- Name: upcoming_page_message_deliveries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_message_deliveries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_message_deliveries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_message_deliveries_id_seq OWNED BY public.upcoming_page_message_deliveries.id;


--
-- Name: upcoming_page_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_messages (
    id integer NOT NULL,
    subject character varying NOT NULL,
    comments_count integer DEFAULT 0 NOT NULL,
    upcoming_page_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state integer DEFAULT 0 NOT NULL,
    slug character varying,
    sent_to_count integer DEFAULT 0 NOT NULL,
    subscriber_filters jsonb DEFAULT '[]'::jsonb NOT NULL,
    user_id integer,
    layout integer DEFAULT 0 NOT NULL,
    upcoming_page_survey_id integer,
    post_id integer,
    visibility integer DEFAULT 0 NOT NULL,
    kind integer DEFAULT 0 NOT NULL,
    body_html text,
    sent_count integer DEFAULT 0,
    opened_count integer DEFAULT 0,
    clicked_count integer DEFAULT 0,
    failed_count integer DEFAULT 0
);


--
-- Name: upcoming_page_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_messages_id_seq OWNED BY public.upcoming_page_messages.id;


--
-- Name: upcoming_page_question_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_question_answers (
    id integer NOT NULL,
    upcoming_page_question_option_id integer,
    upcoming_page_subscriber_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    upcoming_page_question_id integer,
    freeform_text text,
    kind integer DEFAULT 0 NOT NULL
);


--
-- Name: upcoming_page_question_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_question_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_question_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_question_answers_id_seq OWNED BY public.upcoming_page_question_answers.id;


--
-- Name: upcoming_page_question_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_question_options (
    id integer NOT NULL,
    title character varying NOT NULL,
    upcoming_page_question_id integer NOT NULL,
    trashed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upcoming_page_question_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_question_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_question_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_question_options_id_seq OWNED BY public.upcoming_page_question_options.id;


--
-- Name: upcoming_page_question_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_question_rules (
    id integer NOT NULL,
    upcoming_page_question_id integer NOT NULL,
    dependent_upcoming_page_option_id integer NOT NULL,
    dependent_upcoming_page_question_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upcoming_page_question_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_question_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_question_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_question_rules_id_seq OWNED BY public.upcoming_page_question_rules.id;


--
-- Name: upcoming_page_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_questions (
    id integer NOT NULL,
    title character varying NOT NULL,
    trashed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    upcoming_page_survey_id integer NOT NULL,
    position_in_survey integer DEFAULT 0 NOT NULL,
    question_type integer DEFAULT 0 NOT NULL,
    include_other boolean DEFAULT false NOT NULL,
    description character varying,
    required boolean DEFAULT false NOT NULL
);


--
-- Name: upcoming_page_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_questions_id_seq OWNED BY public.upcoming_page_questions.id;


--
-- Name: upcoming_page_segment_subscriber_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_segment_subscriber_associations (
    id integer NOT NULL,
    upcoming_page_segment_id integer NOT NULL,
    upcoming_page_subscriber_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upcoming_page_segment_subscriber_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_segment_subscriber_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_segment_subscriber_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_segment_subscriber_associations_id_seq OWNED BY public.upcoming_page_segment_subscriber_associations.id;


--
-- Name: upcoming_page_segments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_segments (
    id integer NOT NULL,
    name character varying NOT NULL,
    trashed_at timestamp without time zone,
    upcoming_page_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upcoming_page_segments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_segments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_segments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_segments_id_seq OWNED BY public.upcoming_page_segments.id;


--
-- Name: upcoming_page_subscriber_searches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_subscriber_searches (
    id integer NOT NULL,
    upcoming_page_id integer NOT NULL,
    name character varying NOT NULL,
    filters jsonb DEFAULT '[]'::jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upcoming_page_subscriber_searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_subscriber_searches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_subscriber_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_subscriber_searches_id_seq OWNED BY public.upcoming_page_subscriber_searches.id;


--
-- Name: upcoming_page_subscribers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_subscribers (
    id integer NOT NULL,
    token character varying NOT NULL,
    upcoming_page_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state integer DEFAULT 0 NOT NULL,
    source_kind character varying,
    source_reference_id character varying,
    unsubscribe_source character varying,
    ship_contact_id integer NOT NULL
);


--
-- Name: upcoming_page_subscribers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_subscribers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_subscribers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_subscribers_id_seq OWNED BY public.upcoming_page_subscribers.id;


--
-- Name: upcoming_page_surveys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_surveys (
    id integer NOT NULL,
    title character varying NOT NULL,
    upcoming_page_id integer NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    trashed_at timestamp without time zone,
    background_image_uuid character varying,
    background_color character varying,
    button_color character varying,
    title_color character varying,
    link_color character varying,
    button_text_color character varying,
    closed_at timestamp without time zone,
    description_html text,
    success_html text,
    welcome_html text
);


--
-- Name: upcoming_page_surveys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_surveys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_surveys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_surveys_id_seq OWNED BY public.upcoming_page_surveys.id;


--
-- Name: upcoming_page_topic_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_topic_associations (
    id integer NOT NULL,
    upcoming_page_id integer NOT NULL,
    topic_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upcoming_page_topic_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_topic_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_topic_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_topic_associations_id_seq OWNED BY public.upcoming_page_topic_associations.id;


--
-- Name: upcoming_page_variants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_page_variants (
    id integer NOT NULL,
    upcoming_page_id integer NOT NULL,
    kind integer NOT NULL,
    logo_uuid character varying,
    brand_color character varying,
    background_image_uuid character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unsplash_background_url character varying,
    thumbnail_uuid character varying,
    template_name character varying DEFAULT 'default'::character varying NOT NULL,
    background_color character varying,
    media jsonb,
    why_html text,
    what_html text,
    who_html text
);


--
-- Name: upcoming_page_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_page_variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_page_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_page_variants_id_seq OWNED BY public.upcoming_page_variants.id;


--
-- Name: upcoming_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upcoming_pages (
    id integer NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    hiring boolean,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    subscriber_count integer DEFAULT 0 NOT NULL,
    trashed_at timestamp without time zone,
    tagline character varying,
    featured_at timestamp without time zone,
    widget_intro_message character varying,
    webhook_url character varying,
    status integer DEFAULT 0,
    ab_started_at timestamp without time zone,
    import_status integer DEFAULT 0,
    ship_account_id integer NOT NULL,
    seo_title character varying,
    seo_description character varying,
    seo_image_uuid character varying,
    inbox_slug character varying,
    success_html text
);


--
-- Name: upcoming_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upcoming_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upcoming_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upcoming_pages_id_seq OWNED BY public.upcoming_pages.id;


--
-- Name: user_activity_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_activity_events (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    occurred_at timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_activity_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_activity_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_activity_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_activity_events_id_seq OWNED BY public.user_activity_events.id;


--
-- Name: user_delete_surveys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_delete_surveys (
    id integer NOT NULL,
    reason character varying NOT NULL,
    feedback text,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_delete_surveys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_delete_surveys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_delete_surveys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_delete_surveys_id_seq OWNED BY public.user_delete_surveys.id;


--
-- Name: user_follow_product_request_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_follow_product_request_associations (
    id integer NOT NULL,
    user_id integer NOT NULL,
    product_request_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source_id integer
);


--
-- Name: user_follow_product_request_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_follow_product_request_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_follow_product_request_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_follow_product_request_associations_id_seq OWNED BY public.user_follow_product_request_associations.id;


--
-- Name: user_friend_associations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_friend_associations (
    id integer NOT NULL,
    followed_by_user_id integer NOT NULL,
    following_user_id integer NOT NULL,
    created_at timestamp without time zone,
    source character varying,
    source_component character varying
);


--
-- Name: user_friend_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_friend_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_friend_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_friend_associations_id_seq OWNED BY public.user_friend_associations.id;


--
-- Name: user_visit_streak_reminders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_visit_streak_reminders (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    streak_duration integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_visit_streak_reminders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_visit_streak_reminders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_visit_streak_reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_visit_streak_reminders_id_seq OWNED BY public.user_visit_streak_reminders.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(255),
    username character varying(255),
    twitter_uid character varying(255),
    image text,
    headline character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    login_count integer DEFAULT 1 NOT NULL,
    role integer DEFAULT 0,
    invited_by_id integer,
    via_application_id integer,
    twitter_access_token text,
    twitter_access_secret text,
    last_twitter_sync_at timestamp without time zone,
    follower_count integer DEFAULT 0 NOT NULL,
    friend_count integer DEFAULT 0 NOT NULL,
    website_url character varying(255),
    last_twitter_sync_error text,
    twitter_verified boolean DEFAULT false NOT NULL,
    avatar text,
    beta_tester boolean DEFAULT false NOT NULL,
    twitter_username text,
    facebook_uid bigint,
    trashed_at timestamp without time zone,
    last_friend_sync_at timestamp without time zone,
    notification_preferences jsonb DEFAULT '{}'::jsonb NOT NULL,
    header_uuid character varying,
    private_profile boolean DEFAULT false,
    helpful_recommendations_count integer DEFAULT 0 NOT NULL,
    angellist_uid character varying,
    product_requests_count integer DEFAULT 0 NOT NULL,
    recommendations_count integer DEFAULT 0 NOT NULL,
    user_follow_product_request_associations_count integer DEFAULT 0 NOT NULL,
    hide_hiring_badge boolean DEFAULT false NOT NULL,
    goals_count integer DEFAULT 0 NOT NULL,
    completed_goals_count integer DEFAULT 0 NOT NULL,
    maker_group_memberships_count integer DEFAULT 0 NOT NULL,
    confirmed_age boolean DEFAULT false NOT NULL,
    receive_direct_messages boolean DEFAULT true NOT NULL,
    chat_preferences integer DEFAULT 100 NOT NULL,
    location character varying,
    job_role character varying,
    skills character varying[] DEFAULT '{}'::character varying[],
    job_search boolean DEFAULT false,
    google_uid character varying,
    role_reason integer,
    country character varying,
    state character varying,
    city character varying,
    job_preference jsonb DEFAULT '{}'::jsonb NOT NULL,
    default_goal_session_duration integer DEFAULT 25 NOT NULL,
    notification_feed_items_unread_count integer,
    notification_feed_last_seen_at timestamp without time zone,
    last_active_at date,
    avatar_uploaded_at timestamp without time zone,
    karma_points integer,
    karma_points_updated_at timestamp without time zone,
    user_flags_count integer DEFAULT 0,
    welcome_email_sent boolean,
    comments_count integer DEFAULT 0 NOT NULL,
    posts_count integer DEFAULT 0 NOT NULL,
    product_makers_count integer DEFAULT 0 NOT NULL,
    last_user_agent character varying,
    votes_count integer DEFAULT 0 NOT NULL,
    collections_count integer DEFAULT 0 NOT NULL,
    subscribed_collections_count integer DEFAULT 0 NOT NULL,
    upcoming_pages_count integer DEFAULT 0 NOT NULL,
    subscribed_upcoming_pages_count integer DEFAULT 0 NOT NULL,
    apple_uid character varying,
    ambassador boolean,
    badges_count integer DEFAULT 0 NOT NULL,
    default_collection_id bigint,
    badges_unique_count integer DEFAULT 0 NOT NULL,
    mobile_devices_count integer DEFAULT 0 NOT NULL,
    about text,
    activity_events_count integer,
    last_active_ip character varying
);


--
-- Name: users_browser_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_browser_logs (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    browsers character varying[] DEFAULT '{}'::character varying[],
    devices character varying[] DEFAULT '{}'::character varying[],
    platforms character varying[] DEFAULT '{}'::character varying[],
    countries character varying[] DEFAULT '{}'::character varying[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_browser_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_browser_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_browser_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_browser_logs_id_seq OWNED BY public.users_browser_logs.id;


--
-- Name: users_crypto_wallets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_crypto_wallets (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    address character varying NOT NULL,
    provider character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_crypto_wallets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_crypto_wallets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_crypto_wallets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_crypto_wallets_id_seq OWNED BY public.users_crypto_wallets.id;


--
-- Name: users_deleted_karma_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_deleted_karma_logs (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    subject_type character varying NOT NULL,
    karma_value integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_deleted_karma_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_deleted_karma_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_deleted_karma_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_deleted_karma_logs_id_seq OWNED BY public.users_deleted_karma_logs.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_links (
    id bigint NOT NULL,
    name character varying NOT NULL,
    url character varying NOT NULL,
    kind character varying DEFAULT 'website'::character varying NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_links_id_seq OWNED BY public.users_links.id;


--
-- Name: users_new_social_logins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_new_social_logins (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    state character varying DEFAULT 'requested'::character varying NOT NULL,
    social character varying NOT NULL,
    email character varying NOT NULL,
    token character varying NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    auth_response jsonb NOT NULL,
    via_application_id integer
);


--
-- Name: users_new_social_logins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_new_social_logins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_new_social_logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_new_social_logins_id_seq OWNED BY public.users_new_social_logins.id;


--
-- Name: users_registration_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_registration_reasons (
    id bigint NOT NULL,
    source_component character varying,
    origin_url character varying,
    app character varying,
    user_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    provider character varying
);


--
-- Name: users_registration_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_registration_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_registration_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_registration_reasons_id_seq OWNED BY public.users_registration_reasons.id;


--
-- Name: visit_streaks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visit_streaks (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    started_at timestamp without time zone NOT NULL,
    ended_at timestamp without time zone,
    last_visit_at timestamp without time zone NOT NULL,
    duration integer DEFAULT 1 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    last_web_visit_at timestamp without time zone,
    last_ios_visit_at timestamp without time zone,
    last_android_visit_at timestamp without time zone
);


--
-- Name: visit_streaks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visit_streaks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visit_streaks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visit_streaks_id_seq OWNED BY public.visit_streaks.id;


--
-- Name: vote_check_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vote_check_results (
    id integer NOT NULL,
    vote_id integer NOT NULL,
    "check" integer NOT NULL,
    spam_score integer DEFAULT 0 NOT NULL,
    vote_ring_score integer DEFAULT 0 NOT NULL
);


--
-- Name: vote_check_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vote_check_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_check_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vote_check_results_id_seq OWNED BY public.vote_check_results.id;


--
-- Name: vote_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vote_infos (
    id integer NOT NULL,
    vote_id integer NOT NULL,
    request_ip inet,
    first_referer text,
    oauth_application_id integer,
    visit_duration integer,
    user_agent text,
    device_type text,
    os text,
    browser text,
    country text
);


--
-- Name: vote_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vote_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vote_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vote_infos_id_seq OWNED BY public.vote_infos.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
    id integer NOT NULL,
    subject_type text NOT NULL,
    subject_id integer NOT NULL,
    user_id integer NOT NULL,
    credible boolean DEFAULT true NOT NULL,
    sandboxed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    source character varying,
    source_component character varying
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;


--
-- Name: awsdms_ddl_audit; Type: TABLE; Schema: replication_schema; Owner: -
--

CREATE TABLE replication_schema.awsdms_ddl_audit (
    c_key bigint NOT NULL,
    c_time timestamp without time zone,
    c_user character varying(64),
    c_txn character varying(16),
    c_tag character varying(24),
    c_oid integer,
    c_name character varying(64),
    c_schema character varying(64),
    c_ddlqry text
);


--
-- Name: awsdms_ddl_audit_c_key_seq; Type: SEQUENCE; Schema: replication_schema; Owner: -
--

CREATE SEQUENCE replication_schema.awsdms_ddl_audit_c_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: awsdms_ddl_audit_c_key_seq; Type: SEQUENCE OWNED BY; Schema: replication_schema; Owner: -
--

ALTER SEQUENCE replication_schema.awsdms_ddl_audit_c_key_seq OWNED BY replication_schema.awsdms_ddl_audit.c_key;


--
-- Name: ab_test_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_test_participants ALTER COLUMN id SET DEFAULT nextval('public.ab_test_participants_id_seq'::regclass);


--
-- Name: access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens ALTER COLUMN id SET DEFAULT nextval('public.access_tokens_id_seq'::regclass);


--
-- Name: active_admin_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments ALTER COLUMN id SET DEFAULT nextval('public.active_admin_comments_id_seq'::regclass);


--
-- Name: ads_budgets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_budgets ALTER COLUMN id SET DEFAULT nextval('public.ads_budgets_id_seq'::regclass);


--
-- Name: ads_campaigns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_campaigns ALTER COLUMN id SET DEFAULT nextval('public.ads_campaigns_id_seq'::regclass);


--
-- Name: ads_channels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_channels ALTER COLUMN id SET DEFAULT nextval('public.ads_channels_id_seq'::regclass);


--
-- Name: ads_interactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_interactions ALTER COLUMN id SET DEFAULT nextval('public.ads_interactions_id_seq'::regclass);


--
-- Name: ads_newsletter_interactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_newsletter_interactions ALTER COLUMN id SET DEFAULT nextval('public.ads_newsletter_interactions_id_seq'::regclass);


--
-- Name: ads_newsletter_sponsors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_newsletter_sponsors ALTER COLUMN id SET DEFAULT nextval('public.ads_newsletter_sponsors_id_seq'::regclass);


--
-- Name: ads_newsletters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_newsletters ALTER COLUMN id SET DEFAULT nextval('public.ads_newsletters_id_seq'::regclass);


--
-- Name: anthologies_related_story_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthologies_related_story_associations ALTER COLUMN id SET DEFAULT nextval('public.anthologies_related_story_associations_id_seq'::regclass);


--
-- Name: anthologies_stories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthologies_stories ALTER COLUMN id SET DEFAULT nextval('public.anthologies_stories_id_seq'::regclass);


--
-- Name: anthologies_story_mentions_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthologies_story_mentions_associations ALTER COLUMN id SET DEFAULT nextval('public.anthologies_story_mentions_associations_id_seq'::regclass);


--
-- Name: audits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits ALTER COLUMN id SET DEFAULT nextval('public.audits_id_seq'::regclass);


--
-- Name: awsdms_ddl_audit c_key; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.awsdms_ddl_audit ALTER COLUMN c_key SET DEFAULT nextval('public.awsdms_ddl_audit_c_key_seq'::regclass);


--
-- Name: badges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges ALTER COLUMN id SET DEFAULT nextval('public.badges_id_seq'::regclass);


--
-- Name: badges_awards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges_awards ALTER COLUMN id SET DEFAULT nextval('public.badges_awards_id_seq'::regclass);


--
-- Name: banners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banners ALTER COLUMN id SET DEFAULT nextval('public.banners_id_seq'::regclass);


--
-- Name: browser_extension_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser_extension_settings ALTER COLUMN id SET DEFAULT nextval('public.browser_extension_settings_id_seq'::regclass);


--
-- Name: change_log_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_entries ALTER COLUMN id SET DEFAULT nextval('public.change_log_entries_id_seq'::regclass);


--
-- Name: checkout_page_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_page_logs ALTER COLUMN id SET DEFAULT nextval('public.checkout_page_logs_id_seq'::regclass);


--
-- Name: checkout_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_pages ALTER COLUMN id SET DEFAULT nextval('public.checkout_pages_id_seq'::regclass);


--
-- Name: clearbit_company_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clearbit_company_profiles ALTER COLUMN id SET DEFAULT nextval('public.clearbit_company_profiles_id_seq'::regclass);


--
-- Name: clearbit_people_companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clearbit_people_companies ALTER COLUMN id SET DEFAULT nextval('public.clearbit_people_companies_id_seq'::regclass);


--
-- Name: clearbit_person_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clearbit_person_profiles ALTER COLUMN id SET DEFAULT nextval('public.clearbit_person_profiles_id_seq'::regclass);


--
-- Name: collection_curator_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_curator_associations ALTER COLUMN id SET DEFAULT nextval('public.collection_curator_associations_id_seq'::regclass);


--
-- Name: collection_post_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_post_associations ALTER COLUMN id SET DEFAULT nextval('public.collection_post_associations_id_seq'::regclass);


--
-- Name: collection_product_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_product_associations ALTER COLUMN id SET DEFAULT nextval('public.collection_product_associations_id_seq'::regclass);


--
-- Name: collection_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.collection_subscriptions_id_seq'::regclass);


--
-- Name: collection_topic_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_topic_associations ALTER COLUMN id SET DEFAULT nextval('public.collection_topic_associations_id_seq'::regclass);


--
-- Name: collections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections ALTER COLUMN id SET DEFAULT nextval('public.collections_id_seq'::regclass);


--
-- Name: comment_awards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_awards ALTER COLUMN id SET DEFAULT nextval('public.comment_awards_id_seq'::regclass);


--
-- Name: comment_prompts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_prompts ALTER COLUMN id SET DEFAULT nextval('public.comment_prompts_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: cookie_policy_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cookie_policy_logs ALTER COLUMN id SET DEFAULT nextval('public.cookie_policy_logs_id_seq'::regclass);


--
-- Name: crypto_currency_trackers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crypto_currency_trackers ALTER COLUMN id SET DEFAULT nextval('public.crypto_currency_trackers_id_seq'::regclass);


--
-- Name: disabled_friend_syncs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disabled_friend_syncs ALTER COLUMN id SET DEFAULT nextval('public.disabled_friend_syncs_id_seq'::regclass);


--
-- Name: discussion_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_categories ALTER COLUMN id SET DEFAULT nextval('public.discussion_categories_id_seq'::regclass);


--
-- Name: discussion_category_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_category_associations ALTER COLUMN id SET DEFAULT nextval('public.discussion_category_associations_id_seq'::regclass);


--
-- Name: discussion_threads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_threads ALTER COLUMN id SET DEFAULT nextval('public.discussion_threads_id_seq'::regclass);


--
-- Name: dismissables id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dismissables ALTER COLUMN id SET DEFAULT nextval('public.dismissables_id_seq'::regclass);


--
-- Name: drip_mails_scheduled_mails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drip_mails_scheduled_mails ALTER COLUMN id SET DEFAULT nextval('public.drip_mails_scheduled_mails_id_seq'::regclass);


--
-- Name: email_provider_domains id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_provider_domains ALTER COLUMN id SET DEFAULT nextval('public.email_provider_domains_id_seq'::regclass);


--
-- Name: emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails ALTER COLUMN id SET DEFAULT nextval('public.emails_id_seq'::regclass);


--
-- Name: embeds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.embeds ALTER COLUMN id SET DEFAULT nextval('public.embeds_id_seq'::regclass);


--
-- Name: external_api_responses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_api_responses ALTER COLUMN id SET DEFAULT nextval('public.external_api_responses_id_seq'::regclass);


--
-- Name: file_exports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_exports ALTER COLUMN id SET DEFAULT nextval('public.file_exports_id_seq'::regclass);


--
-- Name: flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags ALTER COLUMN id SET DEFAULT nextval('public.flags_id_seq'::regclass);


--
-- Name: flipper_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_features ALTER COLUMN id SET DEFAULT nextval('public.flipper_features_id_seq'::regclass);


--
-- Name: flipper_gates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_gates ALTER COLUMN id SET DEFAULT nextval('public.flipper_gates_id_seq'::regclass);


--
-- Name: founder_club_access_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_access_requests ALTER COLUMN id SET DEFAULT nextval('public.founder_club_access_requests_id_seq'::regclass);


--
-- Name: founder_club_claims id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_claims ALTER COLUMN id SET DEFAULT nextval('public.founder_club_claims_id_seq'::regclass);


--
-- Name: founder_club_deals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_deals ALTER COLUMN id SET DEFAULT nextval('public.founder_club_deals_id_seq'::regclass);


--
-- Name: founder_club_redemption_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_redemption_codes ALTER COLUMN id SET DEFAULT nextval('public.founder_club_redemption_codes_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: funding_surveys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_surveys ALTER COLUMN id SET DEFAULT nextval('public.funding_surveys_id_seq'::regclass);


--
-- Name: goals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals ALTER COLUMN id SET DEFAULT nextval('public.goals_id_seq'::regclass);


--
-- Name: golden_kitty_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_categories ALTER COLUMN id SET DEFAULT nextval('public.golden_kitty_categories_id_seq'::regclass);


--
-- Name: golden_kitty_edition_sponsors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_edition_sponsors ALTER COLUMN id SET DEFAULT nextval('public.golden_kitty_edition_sponsors_id_seq'::regclass);


--
-- Name: golden_kitty_editions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_editions ALTER COLUMN id SET DEFAULT nextval('public.golden_kitty_editions_id_seq'::regclass);


--
-- Name: golden_kitty_facts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_facts ALTER COLUMN id SET DEFAULT nextval('public.golden_kitty_facts_id_seq'::regclass);


--
-- Name: golden_kitty_finalists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_finalists ALTER COLUMN id SET DEFAULT nextval('public.golden_kitty_finalists_id_seq'::regclass);


--
-- Name: golden_kitty_nominees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_nominees ALTER COLUMN id SET DEFAULT nextval('public.golden_kitty_nominees_id_seq'::regclass);


--
-- Name: golden_kitty_people id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_people ALTER COLUMN id SET DEFAULT nextval('public.golden_kitty_people_id_seq'::regclass);


--
-- Name: golden_kitty_sponsors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_sponsors ALTER COLUMN id SET DEFAULT nextval('public.golden_kitty_sponsors_id_seq'::regclass);


--
-- Name: highlighted_changes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.highlighted_changes ALTER COLUMN id SET DEFAULT nextval('public.highlighted_changes_id_seq'::regclass);


--
-- Name: house_keeper_broken_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.house_keeper_broken_links ALTER COLUMN id SET DEFAULT nextval('public.house_keeper_broken_links_id_seq'::regclass);


--
-- Name: input_suggestions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.input_suggestions ALTER COLUMN id SET DEFAULT nextval('public.input_suggestions_id_seq'::regclass);


--
-- Name: iterable_event_webhook_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iterable_event_webhook_data ALTER COLUMN id SET DEFAULT nextval('public.iterable_event_webhook_data_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: jobs_discount_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs_discount_pages ALTER COLUMN id SET DEFAULT nextval('public.jobs_discount_pages_id_seq'::regclass);


--
-- Name: legacy_product_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_product_links ALTER COLUMN id SET DEFAULT nextval('public.legacy_product_links_id_seq'::regclass);


--
-- Name: legacy_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_products ALTER COLUMN id SET DEFAULT nextval('public.legacy_products_id_seq'::regclass);


--
-- Name: link_spect_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_spect_logs ALTER COLUMN id SET DEFAULT nextval('public.link_spect_logs_id_seq'::regclass);


--
-- Name: link_trackers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_trackers ALTER COLUMN id SET DEFAULT nextval('public.link_trackers_id_seq'::regclass);


--
-- Name: mailjet_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailjet_stats ALTER COLUMN id SET DEFAULT nextval('public.mailjet_stats_id_seq'::regclass);


--
-- Name: maker_activities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_activities ALTER COLUMN id SET DEFAULT nextval('public.maker_activities_id_seq'::regclass);


--
-- Name: maker_fest_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_fest_participants ALTER COLUMN id SET DEFAULT nextval('public.maker_fest_participants_id_seq'::regclass);


--
-- Name: maker_group_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_group_members ALTER COLUMN id SET DEFAULT nextval('public.maker_group_members_id_seq'::regclass);


--
-- Name: maker_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_groups ALTER COLUMN id SET DEFAULT nextval('public.maker_groups_id_seq'::regclass);


--
-- Name: maker_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_reports ALTER COLUMN id SET DEFAULT nextval('public.maker_reports_id_seq'::regclass);


--
-- Name: maker_suggestions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_suggestions ALTER COLUMN id SET DEFAULT nextval('public.maker_suggestions_id_seq'::regclass);


--
-- Name: makers_festival_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_categories ALTER COLUMN id SET DEFAULT nextval('public.makers_festival_categories_id_seq'::regclass);


--
-- Name: makers_festival_editions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_editions ALTER COLUMN id SET DEFAULT nextval('public.makers_festival_editions_id_seq'::regclass);


--
-- Name: makers_festival_makers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_makers ALTER COLUMN id SET DEFAULT nextval('public.makers_festival_makers_id_seq'::regclass);


--
-- Name: makers_festival_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_participants ALTER COLUMN id SET DEFAULT nextval('public.makers_festival_participants_id_seq'::regclass);


--
-- Name: marketing_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_notifications ALTER COLUMN id SET DEFAULT nextval('public.marketing_notifications_id_seq'::regclass);


--
-- Name: media id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media ALTER COLUMN id SET DEFAULT nextval('public.media_id_seq'::regclass);


--
-- Name: mentions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions ALTER COLUMN id SET DEFAULT nextval('public.mentions_id_seq'::regclass);


--
-- Name: mobile_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mobile_devices ALTER COLUMN id SET DEFAULT nextval('public.mobile_devices_id_seq'::regclass);


--
-- Name: moderation_duplicate_post_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_duplicate_post_requests ALTER COLUMN id SET DEFAULT nextval('public.moderation_duplicate_post_requests_id_seq'::regclass);


--
-- Name: moderation_locks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_locks ALTER COLUMN id SET DEFAULT nextval('public.moderation_locks_id_seq'::regclass);


--
-- Name: moderation_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_logs ALTER COLUMN id SET DEFAULT nextval('public.moderation_logs_id_seq'::regclass);


--
-- Name: moderation_skips id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_skips ALTER COLUMN id SET DEFAULT nextval('public.moderation_skips_id_seq'::regclass);


--
-- Name: multi_factor_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.multi_factor_tokens ALTER COLUMN id SET DEFAULT nextval('public.multi_factor_tokens_id_seq'::regclass);


--
-- Name: newsletter_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_events ALTER COLUMN id SET DEFAULT nextval('public.newsletter_events_id_seq'::regclass);


--
-- Name: newsletter_experiments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_experiments ALTER COLUMN id SET DEFAULT nextval('public.newsletter_experiments_id_seq'::regclass);


--
-- Name: newsletter_sponsors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_sponsors ALTER COLUMN id SET DEFAULT nextval('public.newsletter_sponsors_id_seq'::regclass);


--
-- Name: newsletter_variants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_variants ALTER COLUMN id SET DEFAULT nextval('public.newsletter_variants_id_seq'::regclass);


--
-- Name: newsletters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletters ALTER COLUMN id SET DEFAULT nextval('public.newsletters_id_seq'::regclass);


--
-- Name: notification_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_events ALTER COLUMN id SET DEFAULT nextval('public.notification_events_id_seq'::regclass);


--
-- Name: notification_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_logs ALTER COLUMN id SET DEFAULT nextval('public.notification_logs_id_seq'::regclass);


--
-- Name: notification_push_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_push_logs ALTER COLUMN id SET DEFAULT nextval('public.notification_push_logs_id_seq'::regclass);


--
-- Name: notification_subscription_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_subscription_logs ALTER COLUMN id SET DEFAULT nextval('public.notification_subscription_logs_id_seq'::regclass);


--
-- Name: notification_unsubscription_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_unsubscription_logs ALTER COLUMN id SET DEFAULT nextval('public.notification_unsubscription_logs_id_seq'::regclass);


--
-- Name: notifications_subscribers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications_subscribers ALTER COLUMN id SET DEFAULT nextval('public.notifications_subscribers_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: oauth_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_requests ALTER COLUMN id SET DEFAULT nextval('public.oauth_requests_id_seq'::regclass);


--
-- Name: onboarding_reasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onboarding_reasons ALTER COLUMN id SET DEFAULT nextval('public.onboarding_reasons_id_seq'::regclass);


--
-- Name: onboarding_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onboarding_tasks ALTER COLUMN id SET DEFAULT nextval('public.onboarding_tasks_id_seq'::regclass);


--
-- Name: onboardings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onboardings ALTER COLUMN id SET DEFAULT nextval('public.onboardings_id_seq'::regclass);


--
-- Name: page_contents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_contents ALTER COLUMN id SET DEFAULT nextval('public.page_contents_id_seq'::regclass);


--
-- Name: payment_card_update_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_card_update_logs ALTER COLUMN id SET DEFAULT nextval('public.payment_card_update_logs_id_seq'::regclass);


--
-- Name: payment_discounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_discounts ALTER COLUMN id SET DEFAULT nextval('public.payment_discounts_id_seq'::regclass);


--
-- Name: payment_plan_discount_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_plan_discount_associations ALTER COLUMN id SET DEFAULT nextval('public.payment_plan_discount_associations_id_seq'::regclass);


--
-- Name: payment_plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_plans ALTER COLUMN id SET DEFAULT nextval('public.payment_plans_id_seq'::regclass);


--
-- Name: payment_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.payment_subscriptions_id_seq'::regclass);


--
-- Name: pghero_query_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pghero_query_stats ALTER COLUMN id SET DEFAULT nextval('public.pghero_query_stats_id_seq'::regclass);


--
-- Name: poll_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_answers ALTER COLUMN id SET DEFAULT nextval('public.poll_answers_id_seq'::regclass);


--
-- Name: poll_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_options ALTER COLUMN id SET DEFAULT nextval('public.poll_options_id_seq'::regclass);


--
-- Name: polls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.polls ALTER COLUMN id SET DEFAULT nextval('public.polls_id_seq'::regclass);


--
-- Name: post_drafts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_drafts ALTER COLUMN id SET DEFAULT nextval('public.post_drafts_id_seq'::regclass);


--
-- Name: post_item_views_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_item_views_logs ALTER COLUMN id SET DEFAULT nextval('public.post_item_views_logs_id_seq'::regclass);


--
-- Name: post_topic_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_topic_associations ALTER COLUMN id SET DEFAULT nextval('public.post_topic_associations_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: posts_launch_day_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts_launch_day_reports ALTER COLUMN id SET DEFAULT nextval('public.posts_launch_day_reports_id_seq'::regclass);


--
-- Name: product_activity_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_activity_events ALTER COLUMN id SET DEFAULT nextval('public.product_activity_events_id_seq'::regclass);


--
-- Name: product_alternative_suggestions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_alternative_suggestions ALTER COLUMN id SET DEFAULT nextval('public.product_alternative_suggestions_id_seq'::regclass);


--
-- Name: product_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_associations ALTER COLUMN id SET DEFAULT nextval('public.product_associations_id_seq'::regclass);


--
-- Name: product_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories ALTER COLUMN id SET DEFAULT nextval('public.product_categories_id_seq'::regclass);


--
-- Name: product_category_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category_associations ALTER COLUMN id SET DEFAULT nextval('public.product_category_associations_id_seq'::regclass);


--
-- Name: product_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_links ALTER COLUMN id SET DEFAULT nextval('public.product_links_id_seq'::regclass);


--
-- Name: product_makers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_makers ALTER COLUMN id SET DEFAULT nextval('public.product_makers_id_seq'::regclass);


--
-- Name: product_post_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_post_associations ALTER COLUMN id SET DEFAULT nextval('public.product_post_associations_id_seq'::regclass);


--
-- Name: product_request_related_product_request_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_request_related_product_request_associations ALTER COLUMN id SET DEFAULT nextval('public.product_request_related_product_request_associations_id_seq'::regclass);


--
-- Name: product_request_topic_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_request_topic_associations ALTER COLUMN id SET DEFAULT nextval('public.product_request_topic_associations_id_seq'::regclass);


--
-- Name: product_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_requests ALTER COLUMN id SET DEFAULT nextval('public.product_requests_id_seq'::regclass);


--
-- Name: product_review_summaries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_review_summaries ALTER COLUMN id SET DEFAULT nextval('public.product_review_summaries_id_seq'::regclass);


--
-- Name: product_review_summary_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_review_summary_associations ALTER COLUMN id SET DEFAULT nextval('public.product_review_summary_associations_id_seq'::regclass);


--
-- Name: product_scrape_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_scrape_results ALTER COLUMN id SET DEFAULT nextval('public.product_scrape_results_id_seq'::regclass);


--
-- Name: product_screenshots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_screenshots ALTER COLUMN id SET DEFAULT nextval('public.product_screenshots_id_seq'::regclass);


--
-- Name: product_stacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_stacks ALTER COLUMN id SET DEFAULT nextval('public.product_stacks_id_seq'::regclass);


--
-- Name: product_topic_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_topic_associations ALTER COLUMN id SET DEFAULT nextval('public.product_topic_associations_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: products_skip_review_suggestions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products_skip_review_suggestions ALTER COLUMN id SET DEFAULT nextval('public.products_skip_review_suggestions_id_seq'::regclass);


--
-- Name: promoted_analytics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_analytics ALTER COLUMN id SET DEFAULT nextval('public.promoted_analytics_id_seq'::regclass);


--
-- Name: promoted_email_ab_test_variants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_ab_test_variants ALTER COLUMN id SET DEFAULT nextval('public.promoted_email_ab_test_variants_id_seq'::regclass);


--
-- Name: promoted_email_ab_tests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_ab_tests ALTER COLUMN id SET DEFAULT nextval('public.promoted_email_ab_tests_id_seq'::regclass);


--
-- Name: promoted_email_campaign_configs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_campaign_configs ALTER COLUMN id SET DEFAULT nextval('public.promoted_email_campaign_configs_id_seq'::regclass);


--
-- Name: promoted_email_campaigns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_campaigns ALTER COLUMN id SET DEFAULT nextval('public.promoted_email_campaigns_id_seq'::regclass);


--
-- Name: promoted_email_signups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_signups ALTER COLUMN id SET DEFAULT nextval('public.promoted_email_signups_id_seq'::regclass);


--
-- Name: promoted_product_campaigns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_product_campaigns ALTER COLUMN id SET DEFAULT nextval('public.promoted_product_campaigns_id_seq'::regclass);


--
-- Name: promoted_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_products ALTER COLUMN id SET DEFAULT nextval('public.promoted_products_id_seq'::regclass);


--
-- Name: questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions ALTER COLUMN id SET DEFAULT nextval('public.questions_id_seq'::regclass);


--
-- Name: radio_sponsors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radio_sponsors ALTER COLUMN id SET DEFAULT nextval('public.radio_sponsors_id_seq'::regclass);


--
-- Name: recommendations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations ALTER COLUMN id SET DEFAULT nextval('public.recommendations_id_seq'::regclass);


--
-- Name: recommended_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommended_products ALTER COLUMN id SET DEFAULT nextval('public.recommended_products_id_seq'::regclass);


--
-- Name: review_tag_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_tag_associations ALTER COLUMN id SET DEFAULT nextval('public.review_tag_associations_id_seq'::regclass);


--
-- Name: review_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_tags ALTER COLUMN id SET DEFAULT nextval('public.review_tags_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: search_user_searches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_user_searches ALTER COLUMN id SET DEFAULT nextval('public.search_user_searches_id_seq'::regclass);


--
-- Name: seo_queries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seo_queries ALTER COLUMN id SET DEFAULT nextval('public.seo_queries_id_seq'::regclass);


--
-- Name: seo_structured_data_validation_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seo_structured_data_validation_messages ALTER COLUMN id SET DEFAULT nextval('public.seo_structured_data_validation_messages_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: ship_account_member_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_account_member_associations ALTER COLUMN id SET DEFAULT nextval('public.ship_account_member_associations_id_seq'::regclass);


--
-- Name: ship_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_accounts ALTER COLUMN id SET DEFAULT nextval('public.ship_accounts_id_seq'::regclass);


--
-- Name: ship_aws_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_aws_applications ALTER COLUMN id SET DEFAULT nextval('public.ship_aws_applications_id_seq'::regclass);


--
-- Name: ship_billing_informations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_billing_informations ALTER COLUMN id SET DEFAULT nextval('public.ship_billing_informations_id_seq'::regclass);


--
-- Name: ship_cancellation_reasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_cancellation_reasons ALTER COLUMN id SET DEFAULT nextval('public.ship_cancellation_reasons_id_seq'::regclass);


--
-- Name: ship_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_contacts ALTER COLUMN id SET DEFAULT nextval('public.ship_contacts_id_seq'::regclass);


--
-- Name: ship_instant_access_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_instant_access_pages ALTER COLUMN id SET DEFAULT nextval('public.ship_instant_access_pages_id_seq'::regclass);


--
-- Name: ship_invite_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_invite_codes ALTER COLUMN id SET DEFAULT nextval('public.ship_invite_codes_id_seq'::regclass);


--
-- Name: ship_leads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_leads ALTER COLUMN id SET DEFAULT nextval('public.ship_leads_id_seq'::regclass);


--
-- Name: ship_payment_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_payment_reports ALTER COLUMN id SET DEFAULT nextval('public.ship_payment_reports_id_seq'::regclass);


--
-- Name: ship_stripe_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_stripe_applications ALTER COLUMN id SET DEFAULT nextval('public.ship_stripe_applications_id_seq'::regclass);


--
-- Name: ship_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.ship_subscriptions_id_seq'::regclass);


--
-- Name: ship_tracking_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_tracking_events ALTER COLUMN id SET DEFAULT nextval('public.ship_tracking_events_id_seq'::regclass);


--
-- Name: ship_tracking_identities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_tracking_identities ALTER COLUMN id SET DEFAULT nextval('public.ship_tracking_identities_id_seq'::regclass);


--
-- Name: ship_user_metadata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_user_metadata ALTER COLUMN id SET DEFAULT nextval('public.ship_user_metadata_id_seq'::regclass);


--
-- Name: shoutouts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shoutouts ALTER COLUMN id SET DEFAULT nextval('public.shoutouts_id_seq'::regclass);


--
-- Name: similar_collection_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.similar_collection_associations ALTER COLUMN id SET DEFAULT nextval('public.similar_collection_associations_id_seq'::regclass);


--
-- Name: spam_action_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_action_logs ALTER COLUMN id SET DEFAULT nextval('public.spam_action_logs_id_seq'::regclass);


--
-- Name: spam_filter_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_filter_values ALTER COLUMN id SET DEFAULT nextval('public.spam_filter_values_id_seq'::regclass);


--
-- Name: spam_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_logs ALTER COLUMN id SET DEFAULT nextval('public.spam_logs_id_seq'::regclass);


--
-- Name: spam_manual_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_manual_logs ALTER COLUMN id SET DEFAULT nextval('public.spam_manual_logs_id_seq'::regclass);


--
-- Name: spam_multiple_accounts_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_multiple_accounts_logs ALTER COLUMN id SET DEFAULT nextval('public.spam_multiple_accounts_logs_id_seq'::regclass);


--
-- Name: spam_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_reports ALTER COLUMN id SET DEFAULT nextval('public.spam_reports_id_seq'::regclass);


--
-- Name: spam_rule_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rule_logs ALTER COLUMN id SET DEFAULT nextval('public.spam_rule_logs_id_seq'::regclass);


--
-- Name: spam_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rules ALTER COLUMN id SET DEFAULT nextval('public.spam_rules_id_seq'::regclass);


--
-- Name: spam_rulesets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rulesets ALTER COLUMN id SET DEFAULT nextval('public.spam_rulesets_id_seq'::regclass);


--
-- Name: stream_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_events ALTER COLUMN id SET DEFAULT nextval('public.stream_events_id_seq'::regclass);


--
-- Name: stream_feed_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_feed_items ALTER COLUMN id SET DEFAULT nextval('public.stream_feed_items_id_seq'::regclass);


--
-- Name: subject_media_modifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_media_modifications ALTER COLUMN id SET DEFAULT nextval('public.subject_media_modifications_id_seq'::regclass);


--
-- Name: subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions ALTER COLUMN id SET DEFAULT nextval('public.subscriptions_id_seq'::regclass);


--
-- Name: team_invites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invites ALTER COLUMN id SET DEFAULT nextval('public.team_invites_id_seq'::regclass);


--
-- Name: team_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members ALTER COLUMN id SET DEFAULT nextval('public.team_members_id_seq'::regclass);


--
-- Name: team_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_requests ALTER COLUMN id SET DEFAULT nextval('public.team_requests_id_seq'::regclass);


--
-- Name: topic_aliases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_aliases ALTER COLUMN id SET DEFAULT nextval('public.topic_aliases_id_seq'::regclass);


--
-- Name: topic_user_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_user_associations ALTER COLUMN id SET DEFAULT nextval('public.topic_user_associations_id_seq'::regclass);


--
-- Name: topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topics ALTER COLUMN id SET DEFAULT nextval('public.topics_id_seq'::regclass);


--
-- Name: tracking_pixel_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracking_pixel_logs ALTER COLUMN id SET DEFAULT nextval('public.tracking_pixel_logs_id_seq'::regclass);


--
-- Name: twitter_follower_counts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.twitter_follower_counts ALTER COLUMN id SET DEFAULT nextval('public.twitter_follower_counts_id_seq'::regclass);


--
-- Name: twitter_verified_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.twitter_verified_users ALTER COLUMN id SET DEFAULT nextval('public.twitter_verified_users_id_seq'::regclass);


--
-- Name: upcoming_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_events ALTER COLUMN id SET DEFAULT nextval('public.upcoming_events_id_seq'::regclass);


--
-- Name: upcoming_page_conversation_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_conversation_messages ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_conversation_messages_id_seq'::regclass);


--
-- Name: upcoming_page_conversations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_conversations ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_conversations_id_seq'::regclass);


--
-- Name: upcoming_page_email_imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_email_imports ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_email_imports_id_seq'::regclass);


--
-- Name: upcoming_page_email_replies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_email_replies ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_email_replies_id_seq'::regclass);


--
-- Name: upcoming_page_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_links ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_links_id_seq'::regclass);


--
-- Name: upcoming_page_maker_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_maker_tasks ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_maker_tasks_id_seq'::regclass);


--
-- Name: upcoming_page_message_deliveries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_message_deliveries ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_message_deliveries_id_seq'::regclass);


--
-- Name: upcoming_page_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_messages ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_messages_id_seq'::regclass);


--
-- Name: upcoming_page_question_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_question_answers ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_question_answers_id_seq'::regclass);


--
-- Name: upcoming_page_question_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_question_options ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_question_options_id_seq'::regclass);


--
-- Name: upcoming_page_question_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_question_rules ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_question_rules_id_seq'::regclass);


--
-- Name: upcoming_page_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_questions ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_questions_id_seq'::regclass);


--
-- Name: upcoming_page_segment_subscriber_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_segment_subscriber_associations ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_segment_subscriber_associations_id_seq'::regclass);


--
-- Name: upcoming_page_segments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_segments ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_segments_id_seq'::regclass);


--
-- Name: upcoming_page_subscriber_searches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_subscriber_searches ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_subscriber_searches_id_seq'::regclass);


--
-- Name: upcoming_page_subscribers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_subscribers ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_subscribers_id_seq'::regclass);


--
-- Name: upcoming_page_surveys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_surveys ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_surveys_id_seq'::regclass);


--
-- Name: upcoming_page_topic_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_topic_associations ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_topic_associations_id_seq'::regclass);


--
-- Name: upcoming_page_variants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_variants ALTER COLUMN id SET DEFAULT nextval('public.upcoming_page_variants_id_seq'::regclass);


--
-- Name: upcoming_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_pages ALTER COLUMN id SET DEFAULT nextval('public.upcoming_pages_id_seq'::regclass);


--
-- Name: user_activity_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_activity_events ALTER COLUMN id SET DEFAULT nextval('public.user_activity_events_id_seq'::regclass);


--
-- Name: user_delete_surveys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_delete_surveys ALTER COLUMN id SET DEFAULT nextval('public.user_delete_surveys_id_seq'::regclass);


--
-- Name: user_follow_product_request_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_follow_product_request_associations ALTER COLUMN id SET DEFAULT nextval('public.user_follow_product_request_associations_id_seq'::regclass);


--
-- Name: user_friend_associations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_friend_associations ALTER COLUMN id SET DEFAULT nextval('public.user_friend_associations_id_seq'::regclass);


--
-- Name: user_visit_streak_reminders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_visit_streak_reminders ALTER COLUMN id SET DEFAULT nextval('public.user_visit_streak_reminders_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_browser_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_browser_logs ALTER COLUMN id SET DEFAULT nextval('public.users_browser_logs_id_seq'::regclass);


--
-- Name: users_crypto_wallets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_crypto_wallets ALTER COLUMN id SET DEFAULT nextval('public.users_crypto_wallets_id_seq'::regclass);


--
-- Name: users_deleted_karma_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_deleted_karma_logs ALTER COLUMN id SET DEFAULT nextval('public.users_deleted_karma_logs_id_seq'::regclass);


--
-- Name: users_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_links ALTER COLUMN id SET DEFAULT nextval('public.users_links_id_seq'::regclass);


--
-- Name: users_new_social_logins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_new_social_logins ALTER COLUMN id SET DEFAULT nextval('public.users_new_social_logins_id_seq'::regclass);


--
-- Name: users_registration_reasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_registration_reasons ALTER COLUMN id SET DEFAULT nextval('public.users_registration_reasons_id_seq'::regclass);


--
-- Name: visit_streaks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_streaks ALTER COLUMN id SET DEFAULT nextval('public.visit_streaks_id_seq'::regclass);


--
-- Name: vote_check_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vote_check_results ALTER COLUMN id SET DEFAULT nextval('public.vote_check_results_id_seq'::regclass);


--
-- Name: vote_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vote_infos ALTER COLUMN id SET DEFAULT nextval('public.vote_infos_id_seq'::regclass);


--
-- Name: votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);


--
-- Name: awsdms_ddl_audit c_key; Type: DEFAULT; Schema: replication_schema; Owner: -
--

ALTER TABLE ONLY replication_schema.awsdms_ddl_audit ALTER COLUMN c_key SET DEFAULT nextval('replication_schema.awsdms_ddl_audit_c_key_seq'::regclass);


--
-- Name: ab_test_participants ab_test_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_test_participants
    ADD CONSTRAINT ab_test_participants_pkey PRIMARY KEY (id);


--
-- Name: access_tokens access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (id);


--
-- Name: active_admin_comments active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: ads_budgets ads_budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_budgets
    ADD CONSTRAINT ads_budgets_pkey PRIMARY KEY (id);


--
-- Name: ads_campaigns ads_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_campaigns
    ADD CONSTRAINT ads_campaigns_pkey PRIMARY KEY (id);


--
-- Name: ads_channels ads_channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_channels
    ADD CONSTRAINT ads_channels_pkey PRIMARY KEY (id);


--
-- Name: ads_interactions ads_interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_interactions
    ADD CONSTRAINT ads_interactions_pkey PRIMARY KEY (id);


--
-- Name: ads_newsletter_interactions ads_newsletter_interactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_newsletter_interactions
    ADD CONSTRAINT ads_newsletter_interactions_pkey PRIMARY KEY (id);


--
-- Name: ads_newsletter_sponsors ads_newsletter_sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_newsletter_sponsors
    ADD CONSTRAINT ads_newsletter_sponsors_pkey PRIMARY KEY (id);


--
-- Name: ads_newsletters ads_newsletters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_newsletters
    ADD CONSTRAINT ads_newsletters_pkey PRIMARY KEY (id);


--
-- Name: anthologies_related_story_associations anthologies_related_story_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthologies_related_story_associations
    ADD CONSTRAINT anthologies_related_story_associations_pkey PRIMARY KEY (id);


--
-- Name: anthologies_stories anthologies_stories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthologies_stories
    ADD CONSTRAINT anthologies_stories_pkey PRIMARY KEY (id);


--
-- Name: anthologies_story_mentions_associations anthologies_story_mentions_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthologies_story_mentions_associations
    ADD CONSTRAINT anthologies_story_mentions_associations_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: awsdms_ddl_audit awsdms_ddl_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.awsdms_ddl_audit
    ADD CONSTRAINT awsdms_ddl_audit_pkey PRIMARY KEY (c_key);


--
-- Name: badges_awards badges_awards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges_awards
    ADD CONSTRAINT badges_awards_pkey PRIMARY KEY (id);


--
-- Name: badges badges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.badges
    ADD CONSTRAINT badges_pkey PRIMARY KEY (id);


--
-- Name: banners banners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banners
    ADD CONSTRAINT banners_pkey PRIMARY KEY (id);


--
-- Name: browser_extension_settings browser_extension_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser_extension_settings
    ADD CONSTRAINT browser_extension_settings_pkey PRIMARY KEY (id);


--
-- Name: change_log_entries change_log_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_entries
    ADD CONSTRAINT change_log_entries_pkey PRIMARY KEY (id);


--
-- Name: checkout_page_logs checkout_page_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_page_logs
    ADD CONSTRAINT checkout_page_logs_pkey PRIMARY KEY (id);


--
-- Name: checkout_pages checkout_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checkout_pages
    ADD CONSTRAINT checkout_pages_pkey PRIMARY KEY (id);


--
-- Name: clearbit_company_profiles clearbit_company_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clearbit_company_profiles
    ADD CONSTRAINT clearbit_company_profiles_pkey PRIMARY KEY (id);


--
-- Name: clearbit_people_companies clearbit_people_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clearbit_people_companies
    ADD CONSTRAINT clearbit_people_companies_pkey PRIMARY KEY (id);


--
-- Name: clearbit_person_profiles clearbit_person_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clearbit_person_profiles
    ADD CONSTRAINT clearbit_person_profiles_pkey PRIMARY KEY (id);


--
-- Name: collection_curator_associations collection_curator_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_curator_associations
    ADD CONSTRAINT collection_curator_associations_pkey PRIMARY KEY (id);


--
-- Name: collection_product_associations collection_product_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_product_associations
    ADD CONSTRAINT collection_product_associations_pkey PRIMARY KEY (id);


--
-- Name: collection_subscriptions collection_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_subscriptions
    ADD CONSTRAINT collection_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: collection_topic_associations collection_topic_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_topic_associations
    ADD CONSTRAINT collection_topic_associations_pkey PRIMARY KEY (id);


--
-- Name: comment_awards comment_awards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_awards
    ADD CONSTRAINT comment_awards_pkey PRIMARY KEY (id);


--
-- Name: comment_prompts comment_prompts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_prompts
    ADD CONSTRAINT comment_prompts_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: cookie_policy_logs cookie_policy_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cookie_policy_logs
    ADD CONSTRAINT cookie_policy_logs_pkey PRIMARY KEY (id);


--
-- Name: crypto_currency_trackers crypto_currency_trackers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crypto_currency_trackers
    ADD CONSTRAINT crypto_currency_trackers_pkey PRIMARY KEY (id);


--
-- Name: disabled_friend_syncs disabled_friend_syncs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disabled_friend_syncs
    ADD CONSTRAINT disabled_friend_syncs_pkey PRIMARY KEY (id);


--
-- Name: discussion_categories discussion_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_categories
    ADD CONSTRAINT discussion_categories_pkey PRIMARY KEY (id);


--
-- Name: discussion_category_associations discussion_category_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_category_associations
    ADD CONSTRAINT discussion_category_associations_pkey PRIMARY KEY (id);


--
-- Name: discussion_threads discussion_threads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_threads
    ADD CONSTRAINT discussion_threads_pkey PRIMARY KEY (id);


--
-- Name: dismissables dismissables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dismissables
    ADD CONSTRAINT dismissables_pkey PRIMARY KEY (id);


--
-- Name: drip_mails_scheduled_mails drip_mails_scheduled_mails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drip_mails_scheduled_mails
    ADD CONSTRAINT drip_mails_scheduled_mails_pkey PRIMARY KEY (id);


--
-- Name: email_provider_domains email_provider_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_provider_domains
    ADD CONSTRAINT email_provider_domains_pkey PRIMARY KEY (id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: embeds embeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.embeds
    ADD CONSTRAINT embeds_pkey PRIMARY KEY (id);


--
-- Name: external_api_responses external_api_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_api_responses
    ADD CONSTRAINT external_api_responses_pkey PRIMARY KEY (id);


--
-- Name: file_exports file_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_exports
    ADD CONSTRAINT file_exports_pkey PRIMARY KEY (id);


--
-- Name: flags flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT flags_pkey PRIMARY KEY (id);


--
-- Name: flipper_features flipper_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_features
    ADD CONSTRAINT flipper_features_pkey PRIMARY KEY (id);


--
-- Name: flipper_gates flipper_gates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flipper_gates
    ADD CONSTRAINT flipper_gates_pkey PRIMARY KEY (id);


--
-- Name: founder_club_access_requests founder_club_access_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_access_requests
    ADD CONSTRAINT founder_club_access_requests_pkey PRIMARY KEY (id);


--
-- Name: founder_club_claims founder_club_claims_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_claims
    ADD CONSTRAINT founder_club_claims_pkey PRIMARY KEY (id);


--
-- Name: founder_club_deals founder_club_deals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_deals
    ADD CONSTRAINT founder_club_deals_pkey PRIMARY KEY (id);


--
-- Name: founder_club_redemption_codes founder_club_redemption_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_redemption_codes
    ADD CONSTRAINT founder_club_redemption_codes_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: funding_surveys funding_surveys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_surveys
    ADD CONSTRAINT funding_surveys_pkey PRIMARY KEY (id);


--
-- Name: goals goals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_pkey PRIMARY KEY (id);


--
-- Name: golden_kitty_categories golden_kitty_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_categories
    ADD CONSTRAINT golden_kitty_categories_pkey PRIMARY KEY (id);


--
-- Name: golden_kitty_edition_sponsors golden_kitty_edition_sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_edition_sponsors
    ADD CONSTRAINT golden_kitty_edition_sponsors_pkey PRIMARY KEY (id);


--
-- Name: golden_kitty_editions golden_kitty_editions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_editions
    ADD CONSTRAINT golden_kitty_editions_pkey PRIMARY KEY (id);


--
-- Name: golden_kitty_facts golden_kitty_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_facts
    ADD CONSTRAINT golden_kitty_facts_pkey PRIMARY KEY (id);


--
-- Name: golden_kitty_finalists golden_kitty_finalists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_finalists
    ADD CONSTRAINT golden_kitty_finalists_pkey PRIMARY KEY (id);


--
-- Name: golden_kitty_nominees golden_kitty_nominees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_nominees
    ADD CONSTRAINT golden_kitty_nominees_pkey PRIMARY KEY (id);


--
-- Name: golden_kitty_people golden_kitty_people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_people
    ADD CONSTRAINT golden_kitty_people_pkey PRIMARY KEY (id);


--
-- Name: golden_kitty_sponsors golden_kitty_sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_sponsors
    ADD CONSTRAINT golden_kitty_sponsors_pkey PRIMARY KEY (id);


--
-- Name: highlighted_changes highlighted_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.highlighted_changes
    ADD CONSTRAINT highlighted_changes_pkey PRIMARY KEY (id);


--
-- Name: house_keeper_broken_links house_keeper_broken_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.house_keeper_broken_links
    ADD CONSTRAINT house_keeper_broken_links_pkey PRIMARY KEY (id);


--
-- Name: input_suggestions input_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.input_suggestions
    ADD CONSTRAINT input_suggestions_pkey PRIMARY KEY (id);


--
-- Name: iterable_event_webhook_data iterable_event_webhook_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.iterable_event_webhook_data
    ADD CONSTRAINT iterable_event_webhook_data_pkey PRIMARY KEY (id);


--
-- Name: jobs_discount_pages jobs_discount_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs_discount_pages
    ADD CONSTRAINT jobs_discount_pages_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: legacy_product_links legacy_product_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_product_links
    ADD CONSTRAINT legacy_product_links_pkey PRIMARY KEY (id);


--
-- Name: legacy_products legacy_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_products
    ADD CONSTRAINT legacy_products_pkey PRIMARY KEY (id);


--
-- Name: link_spect_logs link_spect_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_spect_logs
    ADD CONSTRAINT link_spect_logs_pkey PRIMARY KEY (id);


--
-- Name: link_trackers link_trackers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link_trackers
    ADD CONSTRAINT link_trackers_pkey PRIMARY KEY (id);


--
-- Name: collection_post_associations list_post_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_post_associations
    ADD CONSTRAINT list_post_associations_pkey PRIMARY KEY (id);


--
-- Name: collections lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: mailjet_stats mailjet_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailjet_stats
    ADD CONSTRAINT mailjet_stats_pkey PRIMARY KEY (id);


--
-- Name: maker_activities maker_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_activities
    ADD CONSTRAINT maker_activities_pkey PRIMARY KEY (id);


--
-- Name: maker_fest_participants maker_fest_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_fest_participants
    ADD CONSTRAINT maker_fest_participants_pkey PRIMARY KEY (id);


--
-- Name: maker_group_members maker_group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_group_members
    ADD CONSTRAINT maker_group_members_pkey PRIMARY KEY (id);


--
-- Name: maker_groups maker_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_groups
    ADD CONSTRAINT maker_groups_pkey PRIMARY KEY (id);


--
-- Name: maker_reports maker_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_reports
    ADD CONSTRAINT maker_reports_pkey PRIMARY KEY (id);


--
-- Name: maker_suggestions maker_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_suggestions
    ADD CONSTRAINT maker_suggestions_pkey PRIMARY KEY (id);


--
-- Name: makers_festival_categories makers_festival_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_categories
    ADD CONSTRAINT makers_festival_categories_pkey PRIMARY KEY (id);


--
-- Name: makers_festival_editions makers_festival_editions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_editions
    ADD CONSTRAINT makers_festival_editions_pkey PRIMARY KEY (id);


--
-- Name: makers_festival_makers makers_festival_makers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_makers
    ADD CONSTRAINT makers_festival_makers_pkey PRIMARY KEY (id);


--
-- Name: makers_festival_participants makers_festival_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_participants
    ADD CONSTRAINT makers_festival_participants_pkey PRIMARY KEY (id);


--
-- Name: marketing_notifications marketing_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_notifications
    ADD CONSTRAINT marketing_notifications_pkey PRIMARY KEY (id);


--
-- Name: media media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (id);


--
-- Name: mentions mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mentions
    ADD CONSTRAINT mentions_pkey PRIMARY KEY (id);


--
-- Name: mobile_devices mobile_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mobile_devices
    ADD CONSTRAINT mobile_devices_pkey PRIMARY KEY (id);


--
-- Name: moderation_duplicate_post_requests moderation_duplicate_post_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_duplicate_post_requests
    ADD CONSTRAINT moderation_duplicate_post_requests_pkey PRIMARY KEY (id);


--
-- Name: moderation_locks moderation_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_locks
    ADD CONSTRAINT moderation_locks_pkey PRIMARY KEY (id);


--
-- Name: moderation_logs moderation_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_logs
    ADD CONSTRAINT moderation_logs_pkey PRIMARY KEY (id);


--
-- Name: moderation_skips moderation_skips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_skips
    ADD CONSTRAINT moderation_skips_pkey PRIMARY KEY (id);


--
-- Name: multi_factor_tokens multi_factor_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.multi_factor_tokens
    ADD CONSTRAINT multi_factor_tokens_pkey PRIMARY KEY (id);


--
-- Name: newsletter_events newsletter_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_events
    ADD CONSTRAINT newsletter_events_pkey PRIMARY KEY (id);


--
-- Name: newsletter_experiments newsletter_experiments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_experiments
    ADD CONSTRAINT newsletter_experiments_pkey PRIMARY KEY (id);


--
-- Name: newsletter_sponsors newsletter_sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_sponsors
    ADD CONSTRAINT newsletter_sponsors_pkey PRIMARY KEY (id);


--
-- Name: newsletter_variants newsletter_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_variants
    ADD CONSTRAINT newsletter_variants_pkey PRIMARY KEY (id);


--
-- Name: newsletters newsletters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletters
    ADD CONSTRAINT newsletters_pkey PRIMARY KEY (id);


--
-- Name: notification_events notification_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_events
    ADD CONSTRAINT notification_events_pkey PRIMARY KEY (id);


--
-- Name: notification_logs notification_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_logs
    ADD CONSTRAINT notification_logs_pkey PRIMARY KEY (id);


--
-- Name: notification_push_logs notification_push_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_push_logs
    ADD CONSTRAINT notification_push_logs_pkey PRIMARY KEY (id);


--
-- Name: notification_subscription_logs notification_subscription_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_subscription_logs
    ADD CONSTRAINT notification_subscription_logs_pkey PRIMARY KEY (id);


--
-- Name: notification_unsubscription_logs notification_unsubscription_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_unsubscription_logs
    ADD CONSTRAINT notification_unsubscription_logs_pkey PRIMARY KEY (id);


--
-- Name: notifications_subscribers notifications_subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications_subscribers
    ADD CONSTRAINT notifications_subscribers_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: oauth_requests oauth_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_requests
    ADD CONSTRAINT oauth_requests_pkey PRIMARY KEY (id);


--
-- Name: onboarding_reasons onboarding_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onboarding_reasons
    ADD CONSTRAINT onboarding_reasons_pkey PRIMARY KEY (id);


--
-- Name: onboarding_tasks onboarding_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onboarding_tasks
    ADD CONSTRAINT onboarding_tasks_pkey PRIMARY KEY (id);


--
-- Name: onboardings onboardings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onboardings
    ADD CONSTRAINT onboardings_pkey PRIMARY KEY (id);


--
-- Name: page_contents page_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_contents
    ADD CONSTRAINT page_contents_pkey PRIMARY KEY (id);


--
-- Name: payment_card_update_logs payment_card_update_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_card_update_logs
    ADD CONSTRAINT payment_card_update_logs_pkey PRIMARY KEY (id);


--
-- Name: payment_discounts payment_discounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_discounts
    ADD CONSTRAINT payment_discounts_pkey PRIMARY KEY (id);


--
-- Name: payment_plan_discount_associations payment_plan_discount_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_plan_discount_associations
    ADD CONSTRAINT payment_plan_discount_associations_pkey PRIMARY KEY (id);


--
-- Name: payment_plans payment_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_plans
    ADD CONSTRAINT payment_plans_pkey PRIMARY KEY (id);


--
-- Name: payment_subscriptions payment_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_subscriptions
    ADD CONSTRAINT payment_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: pghero_query_stats pghero_query_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pghero_query_stats
    ADD CONSTRAINT pghero_query_stats_pkey PRIMARY KEY (id);


--
-- Name: poll_answers poll_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_answers
    ADD CONSTRAINT poll_answers_pkey PRIMARY KEY (id);


--
-- Name: poll_options poll_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_options
    ADD CONSTRAINT poll_options_pkey PRIMARY KEY (id);


--
-- Name: polls polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_pkey PRIMARY KEY (id);


--
-- Name: post_drafts post_drafts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_drafts
    ADD CONSTRAINT post_drafts_pkey PRIMARY KEY (id);


--
-- Name: post_item_views_logs post_item_views_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_item_views_logs
    ADD CONSTRAINT post_item_views_logs_pkey PRIMARY KEY (id);


--
-- Name: post_topic_associations post_topic_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_topic_associations
    ADD CONSTRAINT post_topic_associations_pkey PRIMARY KEY (id);


--
-- Name: posts_launch_day_reports posts_launch_day_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts_launch_day_reports
    ADD CONSTRAINT posts_launch_day_reports_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: product_activity_events product_activity_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_activity_events
    ADD CONSTRAINT product_activity_events_pkey PRIMARY KEY (id);


--
-- Name: product_alternative_suggestions product_alternative_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_alternative_suggestions
    ADD CONSTRAINT product_alternative_suggestions_pkey PRIMARY KEY (id);


--
-- Name: product_associations product_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_associations
    ADD CONSTRAINT product_associations_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- Name: product_category_associations product_category_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_category_associations
    ADD CONSTRAINT product_category_associations_pkey PRIMARY KEY (id);


--
-- Name: product_links product_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_links
    ADD CONSTRAINT product_links_pkey PRIMARY KEY (id);


--
-- Name: product_makers product_makers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_makers
    ADD CONSTRAINT product_makers_pkey PRIMARY KEY (id);


--
-- Name: product_post_associations product_post_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_post_associations
    ADD CONSTRAINT product_post_associations_pkey PRIMARY KEY (id);


--
-- Name: product_request_related_product_request_associations product_request_related_product_request_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_request_related_product_request_associations
    ADD CONSTRAINT product_request_related_product_request_associations_pkey PRIMARY KEY (id);


--
-- Name: product_request_topic_associations product_request_topic_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_request_topic_associations
    ADD CONSTRAINT product_request_topic_associations_pkey PRIMARY KEY (id);


--
-- Name: product_requests product_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_requests
    ADD CONSTRAINT product_requests_pkey PRIMARY KEY (id);


--
-- Name: product_review_summaries product_review_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_review_summaries
    ADD CONSTRAINT product_review_summaries_pkey PRIMARY KEY (id);


--
-- Name: product_review_summary_associations product_review_summary_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_review_summary_associations
    ADD CONSTRAINT product_review_summary_associations_pkey PRIMARY KEY (id);


--
-- Name: product_scrape_results product_scrape_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_scrape_results
    ADD CONSTRAINT product_scrape_results_pkey PRIMARY KEY (id);


--
-- Name: product_screenshots product_screenshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_screenshots
    ADD CONSTRAINT product_screenshots_pkey PRIMARY KEY (id);


--
-- Name: product_stacks product_stacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_stacks
    ADD CONSTRAINT product_stacks_pkey PRIMARY KEY (id);


--
-- Name: product_topic_associations product_topic_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_topic_associations
    ADD CONSTRAINT product_topic_associations_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products_skip_review_suggestions products_skip_review_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products_skip_review_suggestions
    ADD CONSTRAINT products_skip_review_suggestions_pkey PRIMARY KEY (id);


--
-- Name: promoted_analytics promoted_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_analytics
    ADD CONSTRAINT promoted_analytics_pkey PRIMARY KEY (id);


--
-- Name: promoted_email_ab_test_variants promoted_email_ab_test_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_ab_test_variants
    ADD CONSTRAINT promoted_email_ab_test_variants_pkey PRIMARY KEY (id);


--
-- Name: promoted_email_ab_tests promoted_email_ab_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_ab_tests
    ADD CONSTRAINT promoted_email_ab_tests_pkey PRIMARY KEY (id);


--
-- Name: promoted_email_campaign_configs promoted_email_campaign_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_campaign_configs
    ADD CONSTRAINT promoted_email_campaign_configs_pkey PRIMARY KEY (id);


--
-- Name: promoted_email_campaigns promoted_email_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_campaigns
    ADD CONSTRAINT promoted_email_campaigns_pkey PRIMARY KEY (id);


--
-- Name: promoted_email_signups promoted_email_signups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_signups
    ADD CONSTRAINT promoted_email_signups_pkey PRIMARY KEY (id);


--
-- Name: promoted_product_campaigns promoted_product_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_product_campaigns
    ADD CONSTRAINT promoted_product_campaigns_pkey PRIMARY KEY (id);


--
-- Name: promoted_products promoted_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_products
    ADD CONSTRAINT promoted_products_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: radio_sponsors radio_sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.radio_sponsors
    ADD CONSTRAINT radio_sponsors_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_pkey1 PRIMARY KEY (id);


--
-- Name: recommended_products recommended_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommended_products
    ADD CONSTRAINT recommended_products_pkey PRIMARY KEY (id);


--
-- Name: review_tag_associations review_tag_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_tag_associations
    ADD CONSTRAINT review_tag_associations_pkey PRIMARY KEY (id);


--
-- Name: review_tags review_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_tags
    ADD CONSTRAINT review_tags_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: search_user_searches search_user_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_user_searches
    ADD CONSTRAINT search_user_searches_pkey PRIMARY KEY (id);


--
-- Name: seo_queries seo_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seo_queries
    ADD CONSTRAINT seo_queries_pkey PRIMARY KEY (id);


--
-- Name: seo_structured_data_validation_messages seo_structured_data_validation_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seo_structured_data_validation_messages
    ADD CONSTRAINT seo_structured_data_validation_messages_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: ship_account_member_associations ship_account_member_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_account_member_associations
    ADD CONSTRAINT ship_account_member_associations_pkey PRIMARY KEY (id);


--
-- Name: ship_accounts ship_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_accounts
    ADD CONSTRAINT ship_accounts_pkey PRIMARY KEY (id);


--
-- Name: ship_aws_applications ship_aws_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_aws_applications
    ADD CONSTRAINT ship_aws_applications_pkey PRIMARY KEY (id);


--
-- Name: ship_billing_informations ship_billing_informations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_billing_informations
    ADD CONSTRAINT ship_billing_informations_pkey PRIMARY KEY (id);


--
-- Name: ship_cancellation_reasons ship_cancellation_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_cancellation_reasons
    ADD CONSTRAINT ship_cancellation_reasons_pkey PRIMARY KEY (id);


--
-- Name: ship_contacts ship_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_contacts
    ADD CONSTRAINT ship_contacts_pkey PRIMARY KEY (id);


--
-- Name: ship_instant_access_pages ship_instant_access_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_instant_access_pages
    ADD CONSTRAINT ship_instant_access_pages_pkey PRIMARY KEY (id);


--
-- Name: ship_invite_codes ship_invite_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_invite_codes
    ADD CONSTRAINT ship_invite_codes_pkey PRIMARY KEY (id);


--
-- Name: ship_leads ship_leads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_leads
    ADD CONSTRAINT ship_leads_pkey PRIMARY KEY (id);


--
-- Name: ship_payment_reports ship_payment_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_payment_reports
    ADD CONSTRAINT ship_payment_reports_pkey PRIMARY KEY (id);


--
-- Name: ship_stripe_applications ship_stripe_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_stripe_applications
    ADD CONSTRAINT ship_stripe_applications_pkey PRIMARY KEY (id);


--
-- Name: ship_subscriptions ship_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_subscriptions
    ADD CONSTRAINT ship_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: ship_tracking_events ship_tracking_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_tracking_events
    ADD CONSTRAINT ship_tracking_events_pkey PRIMARY KEY (id);


--
-- Name: ship_tracking_identities ship_tracking_identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_tracking_identities
    ADD CONSTRAINT ship_tracking_identities_pkey PRIMARY KEY (id);


--
-- Name: ship_user_metadata ship_user_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_user_metadata
    ADD CONSTRAINT ship_user_metadata_pkey PRIMARY KEY (id);


--
-- Name: shoutouts shoutouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shoutouts
    ADD CONSTRAINT shoutouts_pkey PRIMARY KEY (id);


--
-- Name: similar_collection_associations similar_collection_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.similar_collection_associations
    ADD CONSTRAINT similar_collection_associations_pkey PRIMARY KEY (id);


--
-- Name: spam_action_logs spam_action_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_action_logs
    ADD CONSTRAINT spam_action_logs_pkey PRIMARY KEY (id);


--
-- Name: spam_filter_values spam_filter_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_filter_values
    ADD CONSTRAINT spam_filter_values_pkey PRIMARY KEY (id);


--
-- Name: spam_logs spam_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_logs
    ADD CONSTRAINT spam_logs_pkey PRIMARY KEY (id);


--
-- Name: spam_manual_logs spam_manual_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_manual_logs
    ADD CONSTRAINT spam_manual_logs_pkey PRIMARY KEY (id);


--
-- Name: spam_multiple_accounts_logs spam_multiple_accounts_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_multiple_accounts_logs
    ADD CONSTRAINT spam_multiple_accounts_logs_pkey PRIMARY KEY (id);


--
-- Name: spam_reports spam_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_reports
    ADD CONSTRAINT spam_reports_pkey PRIMARY KEY (id);


--
-- Name: spam_rule_logs spam_rule_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rule_logs
    ADD CONSTRAINT spam_rule_logs_pkey PRIMARY KEY (id);


--
-- Name: spam_rules spam_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rules
    ADD CONSTRAINT spam_rules_pkey PRIMARY KEY (id);


--
-- Name: spam_rulesets spam_rulesets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rulesets
    ADD CONSTRAINT spam_rulesets_pkey PRIMARY KEY (id);


--
-- Name: stream_events stream_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_events
    ADD CONSTRAINT stream_events_pkey PRIMARY KEY (id);


--
-- Name: stream_feed_items stream_feed_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_feed_items
    ADD CONSTRAINT stream_feed_items_pkey PRIMARY KEY (id);


--
-- Name: subject_media_modifications subject_media_modifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_media_modifications
    ADD CONSTRAINT subject_media_modifications_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: team_invites team_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invites
    ADD CONSTRAINT team_invites_pkey PRIMARY KEY (id);


--
-- Name: team_members team_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_pkey PRIMARY KEY (id);


--
-- Name: team_requests team_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_requests
    ADD CONSTRAINT team_requests_pkey PRIMARY KEY (id);


--
-- Name: topic_aliases topic_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_aliases
    ADD CONSTRAINT topic_aliases_pkey PRIMARY KEY (id);


--
-- Name: topic_user_associations topic_user_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_user_associations
    ADD CONSTRAINT topic_user_associations_pkey PRIMARY KEY (id);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: tracking_pixel_logs tracking_pixel_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracking_pixel_logs
    ADD CONSTRAINT tracking_pixel_logs_pkey PRIMARY KEY (id);


--
-- Name: twitter_follower_counts twitter_follower_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.twitter_follower_counts
    ADD CONSTRAINT twitter_follower_counts_pkey PRIMARY KEY (id);


--
-- Name: twitter_verified_users twitter_verified_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.twitter_verified_users
    ADD CONSTRAINT twitter_verified_users_pkey PRIMARY KEY (id);


--
-- Name: upcoming_events upcoming_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_events
    ADD CONSTRAINT upcoming_events_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_conversation_messages upcoming_page_conversation_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_conversation_messages
    ADD CONSTRAINT upcoming_page_conversation_messages_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_conversations upcoming_page_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_conversations
    ADD CONSTRAINT upcoming_page_conversations_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_email_imports upcoming_page_email_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_email_imports
    ADD CONSTRAINT upcoming_page_email_imports_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_email_replies upcoming_page_email_replies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_email_replies
    ADD CONSTRAINT upcoming_page_email_replies_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_links upcoming_page_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_links
    ADD CONSTRAINT upcoming_page_links_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_maker_tasks upcoming_page_maker_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_maker_tasks
    ADD CONSTRAINT upcoming_page_maker_tasks_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_message_deliveries upcoming_page_message_deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_message_deliveries
    ADD CONSTRAINT upcoming_page_message_deliveries_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_messages upcoming_page_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_messages
    ADD CONSTRAINT upcoming_page_messages_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_question_answers upcoming_page_question_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_question_answers
    ADD CONSTRAINT upcoming_page_question_answers_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_question_options upcoming_page_question_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_question_options
    ADD CONSTRAINT upcoming_page_question_options_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_question_rules upcoming_page_question_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_question_rules
    ADD CONSTRAINT upcoming_page_question_rules_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_questions upcoming_page_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_questions
    ADD CONSTRAINT upcoming_page_questions_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_segment_subscriber_associations upcoming_page_segment_subscriber_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_segment_subscriber_associations
    ADD CONSTRAINT upcoming_page_segment_subscriber_associations_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_segments upcoming_page_segments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_segments
    ADD CONSTRAINT upcoming_page_segments_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_subscriber_searches upcoming_page_subscriber_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_subscriber_searches
    ADD CONSTRAINT upcoming_page_subscriber_searches_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_subscribers upcoming_page_subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_subscribers
    ADD CONSTRAINT upcoming_page_subscribers_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_surveys upcoming_page_surveys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_surveys
    ADD CONSTRAINT upcoming_page_surveys_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_topic_associations upcoming_page_topic_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_topic_associations
    ADD CONSTRAINT upcoming_page_topic_associations_pkey PRIMARY KEY (id);


--
-- Name: upcoming_page_variants upcoming_page_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_variants
    ADD CONSTRAINT upcoming_page_variants_pkey PRIMARY KEY (id);


--
-- Name: upcoming_pages upcoming_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_pages
    ADD CONSTRAINT upcoming_pages_pkey PRIMARY KEY (id);


--
-- Name: user_activity_events user_activity_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_activity_events
    ADD CONSTRAINT user_activity_events_pkey PRIMARY KEY (id);


--
-- Name: user_delete_surveys user_delete_surveys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_delete_surveys
    ADD CONSTRAINT user_delete_surveys_pkey PRIMARY KEY (id);


--
-- Name: user_follow_product_request_associations user_follow_product_request_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_follow_product_request_associations
    ADD CONSTRAINT user_follow_product_request_associations_pkey PRIMARY KEY (id);


--
-- Name: user_friend_associations user_friend_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_friend_associations
    ADD CONSTRAINT user_friend_associations_pkey PRIMARY KEY (id);


--
-- Name: user_visit_streak_reminders user_visit_streak_reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_visit_streak_reminders
    ADD CONSTRAINT user_visit_streak_reminders_pkey PRIMARY KEY (id);


--
-- Name: users_browser_logs users_browser_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_browser_logs
    ADD CONSTRAINT users_browser_logs_pkey PRIMARY KEY (id);


--
-- Name: users_crypto_wallets users_crypto_wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_crypto_wallets
    ADD CONSTRAINT users_crypto_wallets_pkey PRIMARY KEY (id);


--
-- Name: users_deleted_karma_logs users_deleted_karma_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_deleted_karma_logs
    ADD CONSTRAINT users_deleted_karma_logs_pkey PRIMARY KEY (id);


--
-- Name: users_links users_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_links
    ADD CONSTRAINT users_links_pkey PRIMARY KEY (id);


--
-- Name: users_new_social_logins users_new_social_logins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_new_social_logins
    ADD CONSTRAINT users_new_social_logins_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_registration_reasons users_registration_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_registration_reasons
    ADD CONSTRAINT users_registration_reasons_pkey PRIMARY KEY (id);


--
-- Name: visit_streaks visit_streaks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_streaks
    ADD CONSTRAINT visit_streaks_pkey PRIMARY KEY (id);


--
-- Name: vote_check_results vote_check_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vote_check_results
    ADD CONSTRAINT vote_check_results_pkey PRIMARY KEY (id);


--
-- Name: vote_infos vote_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vote_infos
    ADD CONSTRAINT vote_infos_pkey PRIMARY KEY (id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: awsdms_ddl_audit awsdms_ddl_audit_pkey; Type: CONSTRAINT; Schema: replication_schema; Owner: -
--

ALTER TABLE ONLY replication_schema.awsdms_ddl_audit
    ADD CONSTRAINT awsdms_ddl_audit_pkey PRIMARY KEY (c_key);


--
-- Name: associated_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX associated_index ON public.audits USING btree (associated_type, associated_id);


--
-- Name: auditable_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auditable_index ON public.audits USING btree (auditable_type, auditable_id, version);


--
-- Name: banner_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX banner_position ON public.banners USING btree ("position");


--
-- Name: banner_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX banner_status ON public.banners USING btree (status);


--
-- Name: collection_topic_associations_collection_topic; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX collection_topic_associations_collection_topic ON public.collection_topic_associations USING btree (collection_id, topic_id);


--
-- Name: highlighted_change_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX highlighted_change_status ON public.highlighted_changes USING btree (status);


--
-- Name: idx_notification_logs_on_kind_and_notifyable_type_and_notify_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_logs_on_kind_and_notifyable_type_and_notify_id ON public.notification_logs USING btree (kind, notifyable_type, notifyable_id);


--
-- Name: index_ab_test_participants_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ab_test_participants_on_user_id ON public.ab_test_participants USING btree (user_id);


--
-- Name: index_access_tokens_on_token_type_and_unavailable_until; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_tokens_on_token_type_and_unavailable_until ON public.access_tokens USING btree (token_type, unavailable_until NULLS FIRST);


--
-- Name: index_access_tokens_on_unavailable_until; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_tokens_on_unavailable_until ON public.access_tokens USING btree (unavailable_until);


--
-- Name: index_access_tokens_on_user_id_and_token_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_access_tokens_on_user_id_and_token_type ON public.access_tokens USING btree (user_id, token_type);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON public.active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON public.active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON public.active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_ads_budgets_on_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_budgets_on_campaign_id ON public.ads_budgets USING btree (campaign_id);


--
-- Name: index_ads_budgets_on_end_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_budgets_on_end_time ON public.ads_budgets USING btree (end_time) WHERE (end_time IS NOT NULL);


--
-- Name: index_ads_budgets_on_start_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_budgets_on_start_time ON public.ads_budgets USING btree (start_time) WHERE (start_time IS NOT NULL);


--
-- Name: index_ads_campaigns_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_campaigns_on_post_id ON public.ads_campaigns USING btree (post_id);


--
-- Name: index_ads_channels_find_ad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_channels_find_ad ON public.ads_channels USING btree (weight DESC, active, kind);


--
-- Name: index_ads_channels_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_channels_on_active ON public.ads_channels USING btree (active);


--
-- Name: index_ads_channels_on_budget_id_and_kind_and_bundle; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ads_channels_on_budget_id_and_kind_and_bundle ON public.ads_channels USING btree (budget_id, kind, bundle);


--
-- Name: index_ads_channels_on_bundle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_channels_on_bundle ON public.ads_channels USING btree (bundle);


--
-- Name: index_ads_channels_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_channels_on_kind ON public.ads_channels USING btree (kind);


--
-- Name: index_ads_interactions_created_at_kind_created_month; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_interactions_created_at_kind_created_month ON public.ads_interactions USING btree (created_at, kind, date_trunc('month'::text, created_at));


--
-- Name: index_ads_interactions_on_channel_id_and_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_interactions_on_channel_id_and_kind ON public.ads_interactions USING btree (channel_id, kind);


--
-- Name: index_ads_interactions_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_interactions_on_kind ON public.ads_interactions USING spgist (kind);


--
-- Name: index_ads_interactions_on_track_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_interactions_on_track_code ON public.ads_interactions USING btree (track_code);


--
-- Name: index_ads_interactions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_interactions_on_user_id ON public.ads_interactions USING btree (user_id);


--
-- Name: index_ads_newsletter_interactions_on_ads_newsletter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_newsletter_interactions_on_ads_newsletter_id ON public.ads_newsletter_interactions USING btree (ads_newsletter_id);


--
-- Name: index_ads_newsletter_interactions_on_subject_columns; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_newsletter_interactions_on_subject_columns ON public.ads_newsletter_interactions USING btree (subject_type, subject_id);


--
-- Name: index_ads_newsletter_interactions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_newsletter_interactions_on_user_id ON public.ads_newsletter_interactions USING btree (user_id);


--
-- Name: index_ads_newsletter_sponsors_on_active_and_weight; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_newsletter_sponsors_on_active_and_weight ON public.ads_newsletter_sponsors USING btree (active, weight);


--
-- Name: index_ads_newsletter_sponsors_on_budget_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_newsletter_sponsors_on_budget_id ON public.ads_newsletter_sponsors USING btree (budget_id);


--
-- Name: index_ads_newsletters_on_active_and_weight; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_newsletters_on_active_and_weight ON public.ads_newsletters USING btree (active, weight);


--
-- Name: index_ads_newsletters_on_budget_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_newsletters_on_budget_id ON public.ads_newsletters USING btree (budget_id);


--
-- Name: index_ads_newsletters_on_newsletter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ads_newsletters_on_newsletter_id ON public.ads_newsletters USING btree (newsletter_id);


--
-- Name: index_alternative_suggestions_on_from_product_id_and_to_product; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_alternative_suggestions_on_from_product_id_and_to_product ON public.product_alternative_suggestions USING btree (product_id, alternative_product_id);


--
-- Name: index_anthologies_related_story_associations_on_related_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_anthologies_related_story_associations_on_related_id ON public.anthologies_related_story_associations USING btree (related_id);


--
-- Name: index_anthologies_related_story_associations_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_anthologies_related_story_associations_unique ON public.anthologies_related_story_associations USING btree (story_id, related_id);


--
-- Name: index_anthologies_stories_on_credible_votes_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_anthologies_stories_on_credible_votes_count ON public.anthologies_stories USING btree (credible_votes_count);


--
-- Name: index_anthologies_stories_on_featured_position; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_anthologies_stories_on_featured_position ON public.anthologies_stories USING btree (featured_position) WHERE (featured_position IS NOT NULL);


--
-- Name: index_anthologies_stories_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_anthologies_stories_on_title ON public.anthologies_stories USING gin (title public.gin_trgm_ops);


--
-- Name: index_anthologies_stories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_anthologies_stories_on_user_id ON public.anthologies_stories USING btree (user_id);


--
-- Name: index_audits_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audits_on_created_at ON public.audits USING btree (created_at);


--
-- Name: index_audits_on_request_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audits_on_request_uuid ON public.audits USING btree (request_uuid);


--
-- Name: index_badges_awards_on_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_badges_awards_on_identifier ON public.badges_awards USING btree (identifier);


--
-- Name: index_badges_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_badges_on_subject_type_and_subject_id ON public.badges USING btree (subject_type, subject_id);


--
-- Name: index_banners_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_banners_on_user_id ON public.banners USING btree (user_id);


--
-- Name: index_browser_extension_settings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_browser_extension_settings_on_user_id ON public.browser_extension_settings USING btree (user_id);


--
-- Name: index_browser_extension_settings_on_visitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_browser_extension_settings_on_visitor_id ON public.browser_extension_settings USING btree (visitor_id);


--
-- Name: index_change_log_entries_on_credible_votes_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_change_log_entries_on_credible_votes_count ON public.change_log_entries USING btree (credible_votes_count);


--
-- Name: index_change_log_entries_on_discussion_thread_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_change_log_entries_on_discussion_thread_id ON public.change_log_entries USING btree (discussion_thread_id);


--
-- Name: index_checkout_page_logs_on_checkout_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_checkout_page_logs_on_checkout_page_id ON public.checkout_page_logs USING btree (checkout_page_id);


--
-- Name: index_checkout_page_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_checkout_page_logs_on_user_id ON public.checkout_page_logs USING btree (user_id);


--
-- Name: index_checkout_pages_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_checkout_pages_on_slug ON public.checkout_pages USING btree (slug);


--
-- Name: index_clearbit_company_profiles_on_domain; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_clearbit_company_profiles_on_domain ON public.clearbit_company_profiles USING btree (domain);


--
-- Name: index_clearbit_people_companies_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clearbit_people_companies_on_company_id ON public.clearbit_people_companies USING btree (company_id);


--
-- Name: index_clearbit_people_companies_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clearbit_people_companies_on_person_id ON public.clearbit_people_companies USING btree (person_id);


--
-- Name: index_clearbit_person_profiles_clearbit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clearbit_person_profiles_clearbit_id ON public.clearbit_person_profiles USING btree (clearbit_id);


--
-- Name: index_clearbit_person_profiles_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_clearbit_person_profiles_on_email ON public.clearbit_person_profiles USING btree (email);


--
-- Name: index_collection_curator_associations_on_user_and_collection; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_curator_associations_on_user_and_collection ON public.collection_curator_associations USING btree (user_id, collection_id);


--
-- Name: index_collection_post_associations_on_collection_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_post_associations_on_collection_id_and_post_id ON public.collection_post_associations USING btree (collection_id, post_id);


--
-- Name: index_collection_post_associations_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_post_associations_on_post_id ON public.collection_post_associations USING btree (post_id);


--
-- Name: index_collection_product_assoc_on_collection_id_and_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_product_assoc_on_collection_id_and_product_id ON public.collection_product_associations USING btree (collection_id, product_id);


--
-- Name: index_collection_product_associations_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_product_associations_on_product_id ON public.collection_product_associations USING btree (product_id);


--
-- Name: index_collection_subscriptions_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_subscriptions_on_collection_id ON public.collection_subscriptions USING btree (collection_id);


--
-- Name: index_collection_subscriptions_on_user_id_and_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collection_subscriptions_on_user_id_and_collection_id ON public.collection_subscriptions USING btree (user_id, collection_id);


--
-- Name: index_collection_subscriptions_on_user_id_and_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collection_subscriptions_on_user_id_and_state ON public.collection_subscriptions USING btree (user_id, state);


--
-- Name: index_collections_on_featured_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_featured_at ON public.collections USING btree (featured_at);


--
-- Name: index_collections_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collections_on_slug ON public.collections USING btree (slug) WHERE (featured_at IS NOT NULL);


--
-- Name: index_collections_on_slug_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collections_on_slug_and_user_id ON public.collections USING btree (slug, user_id);


--
-- Name: index_collections_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_user_id ON public.collections USING btree (user_id);


--
-- Name: index_comment_awards_on_awarded_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_awards_on_awarded_by_id ON public.comment_awards USING btree (awarded_by_id);


--
-- Name: index_comment_awards_on_awarded_by_id_and_awarded_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_comment_awards_on_awarded_by_id_and_awarded_to_id ON public.comment_awards USING btree (awarded_by_id, awarded_to_id);


--
-- Name: index_comment_awards_on_awarded_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_awards_on_awarded_to_id ON public.comment_awards USING btree (awarded_to_id);


--
-- Name: index_comment_awards_on_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_comment_awards_on_comment_id ON public.comment_awards USING btree (comment_id);


--
-- Name: index_comment_prompts_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_prompts_on_post_id ON public.comment_prompts USING btree (post_id);


--
-- Name: index_comments_on_credible_votes_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_credible_votes_count ON public.comments USING btree (credible_votes_count);


--
-- Name: index_comments_on_parent_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_parent_comment_id ON public.comments USING btree (parent_comment_id);


--
-- Name: index_comments_on_subject_and_user_and_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_subject_and_user_and_parent ON public.comments USING btree (subject_type, subject_id, user_id, parent_comment_id);


--
-- Name: index_comments_on_trashed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_trashed_at ON public.comments USING btree (trashed_at);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_user_id ON public.comments USING btree (user_id);


--
-- Name: index_cookie_policy_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cookie_policy_logs_on_user_id ON public.cookie_policy_logs USING btree (user_id);


--
-- Name: index_crypto_currency_trackers_on_token_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_crypto_currency_trackers_on_token_id ON public.crypto_currency_trackers USING btree (token_id);


--
-- Name: index_disabled_friend_syncs_on_following_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_disabled_friend_syncs_on_following_user_id ON public.disabled_friend_syncs USING btree (following_user_id);


--
-- Name: index_disabled_twitter_sync_followed_following; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_disabled_twitter_sync_followed_following ON public.disabled_friend_syncs USING btree (followed_by_user_id, following_user_id);


--
-- Name: index_discussion_categories_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_discussion_categories_on_name ON public.discussion_categories USING btree (name);


--
-- Name: index_discussion_categories_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_discussion_categories_on_slug ON public.discussion_categories USING btree (slug);


--
-- Name: index_discussion_category_associations_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discussion_category_associations_on_category_id ON public.discussion_category_associations USING btree (category_id);


--
-- Name: index_discussion_category_associations_on_discussion_thread_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_discussion_category_associations_on_discussion_thread_id ON public.discussion_category_associations USING btree (discussion_thread_id);


--
-- Name: index_discussion_thread_on_user_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discussion_thread_on_user_subject ON public.discussion_threads USING btree (user_id, subject_id, subject_type);


--
-- Name: index_discussion_threads_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discussion_threads_on_created_at ON public.discussion_threads USING btree (created_at) WHERE (hidden_at IS NULL);


--
-- Name: index_discussion_threads_on_credible_votes_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discussion_threads_on_credible_votes_count ON public.discussion_threads USING btree (credible_votes_count);


--
-- Name: index_discussion_threads_on_featured_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discussion_threads_on_featured_at ON public.discussion_threads USING btree (featured_at) WHERE ((featured_at IS NOT NULL) AND (hidden_at IS NULL));


--
-- Name: index_discussion_threads_on_hidden_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discussion_threads_on_hidden_at ON public.discussion_threads USING btree (hidden_at);


--
-- Name: index_discussion_threads_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_discussion_threads_on_slug ON public.discussion_threads USING btree (slug);


--
-- Name: index_discussion_threads_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discussion_threads_on_status ON public.discussion_threads USING btree (status);


--
-- Name: index_discussion_threads_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discussion_threads_on_subject_type_and_subject_id ON public.discussion_threads USING btree (subject_type, subject_id);


--
-- Name: index_discussion_threads_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discussion_threads_on_title ON public.discussion_threads USING gin (title public.gin_trgm_ops);


--
-- Name: index_discussion_threads_on_trashed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discussion_threads_on_trashed_at ON public.discussion_threads USING btree (trashed_at) WHERE (trashed_at IS NOT NULL);


--
-- Name: index_discussion_threads_on_trending_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_discussion_threads_on_trending_at ON public.discussion_threads USING btree (trending_at) WHERE ((hidden_at IS NULL) AND (trending_at IS NOT NULL));


--
-- Name: index_dismissables_on_dismissable_group_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dismissables_on_dismissable_group_and_user_id ON public.dismissables USING btree (dismissable_group, user_id);


--
-- Name: index_drip_mails_on_mailer_drip_and_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_drip_mails_on_mailer_drip_and_subject ON public.drip_mails_scheduled_mails USING btree (user_id, mailer_name, drip_kind, subject_type, subject_id);


--
-- Name: index_drip_mails_scheduled_mails_on_completed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drip_mails_scheduled_mails_on_completed ON public.drip_mails_scheduled_mails USING btree (completed);


--
-- Name: index_email_provider_domains_on_added_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_provider_domains_on_added_by_id ON public.email_provider_domains USING btree (added_by_id);


--
-- Name: index_email_provider_domains_on_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_email_provider_domains_on_value ON public.email_provider_domains USING btree (value);


--
-- Name: index_emails_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_email ON public.emails USING btree (email);


--
-- Name: index_emails_on_source_kind_and_source_reference_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_source_kind_and_source_reference_id ON public.emails USING btree (source_kind, source_reference_id);


--
-- Name: index_embeds_on_subject_type_and_subject_id_and_clean_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_embeds_on_subject_type_and_subject_id_and_clean_url ON public.embeds USING btree (subject_type, subject_id, clean_url);


--
-- Name: index_external_api_responses_on_params_and_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_external_api_responses_on_params_and_kind ON public.external_api_responses USING gin (params, kind);


--
-- Name: index_file_exports_on_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_exports_on_expires_at ON public.file_exports USING btree (expires_at);


--
-- Name: index_file_exports_on_file_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_file_exports_on_file_key ON public.file_exports USING btree (file_key);


--
-- Name: index_file_exports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_exports_on_user_id ON public.file_exports USING btree (user_id);


--
-- Name: index_flags_on_moderator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flags_on_moderator_id ON public.flags USING btree (moderator_id);


--
-- Name: index_flags_on_reason; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flags_on_reason ON public.flags USING spgist (reason);


--
-- Name: index_flags_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flags_on_status ON public.flags USING spgist (status);


--
-- Name: index_flags_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flags_on_user_id ON public.flags USING btree (user_id);


--
-- Name: index_flipper_features_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_flipper_features_on_key ON public.flipper_features USING btree (key);


--
-- Name: index_flipper_gates_on_feature_key_and_key_and_value; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_flipper_gates_on_feature_key_and_key_and_value ON public.flipper_gates USING btree (feature_key, key, value);


--
-- Name: index_founder_club_access_requests_on_deal_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_founder_club_access_requests_on_deal_id ON public.founder_club_access_requests USING btree (deal_id);


--
-- Name: index_founder_club_access_requests_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founder_club_access_requests_on_email ON public.founder_club_access_requests USING btree (email);


--
-- Name: index_founder_club_access_requests_on_invite_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founder_club_access_requests_on_invite_code ON public.founder_club_access_requests USING btree (invite_code);


--
-- Name: index_founder_club_access_requests_on_invited_by_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_founder_club_access_requests_on_invited_by_user_id ON public.founder_club_access_requests USING btree (invited_by_user_id) WHERE (invited_by_user_id IS NOT NULL);


--
-- Name: index_founder_club_access_requests_on_payment_discount_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_founder_club_access_requests_on_payment_discount_id ON public.founder_club_access_requests USING btree (payment_discount_id);


--
-- Name: index_founder_club_access_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_founder_club_access_requests_on_user_id ON public.founder_club_access_requests USING btree (user_id);


--
-- Name: index_founder_club_claims_on_deal_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founder_club_claims_on_deal_id_and_user_id ON public.founder_club_claims USING btree (deal_id, user_id);


--
-- Name: index_founder_club_claims_on_redemption_code_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_founder_club_claims_on_redemption_code_id ON public.founder_club_claims USING btree (redemption_code_id);


--
-- Name: index_founder_club_claims_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_founder_club_claims_on_user_id ON public.founder_club_claims USING btree (user_id);


--
-- Name: index_founder_club_deals_on_active_and_trashed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_founder_club_deals_on_active_and_trashed_at ON public.founder_club_deals USING btree (active, trashed_at) WHERE ((active = true) AND (trashed_at IS NULL));


--
-- Name: index_founder_club_deals_on_badges; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_founder_club_deals_on_badges ON public.founder_club_deals USING gin (badges);


--
-- Name: index_founder_club_deals_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_founder_club_deals_on_product_id ON public.founder_club_deals USING btree (product_id);


--
-- Name: index_founder_club_redemption_codes_on_deal_id_and_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founder_club_redemption_codes_on_deal_id_and_code ON public.founder_club_redemption_codes USING btree (deal_id, code);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON public.friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON public.friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_funding_surveys_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_funding_surveys_on_post_id ON public.funding_surveys USING btree (post_id);


--
-- Name: index_gk_edition_sponsors_on_edition_id_and_sponsor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gk_edition_sponsors_on_edition_id_and_sponsor_id ON public.golden_kitty_edition_sponsors USING btree (edition_id, sponsor_id);


--
-- Name: index_gk_people_on_position_and_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gk_people_on_position_and_category_id ON public.golden_kitty_people USING btree ("position", golden_kitty_category_id) WHERE ("position" IS NOT NULL);


--
-- Name: index_gk_post_id_category_id_user_id_u; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_gk_post_id_category_id_user_id_u ON public.golden_kitty_nominees USING btree (post_id, golden_kitty_category_id, user_id);


--
-- Name: index_goals_on_completed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_goals_on_completed_at ON public.goals USING btree (completed_at);


--
-- Name: index_goals_on_due_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_goals_on_due_at ON public.goals USING btree (due_at);


--
-- Name: index_goals_on_feed_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_goals_on_feed_date ON public.goals USING btree (feed_date) WHERE (hidden_at IS NULL);


--
-- Name: index_goals_on_hidden_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_goals_on_hidden_at ON public.goals USING btree (hidden_at);


--
-- Name: index_goals_on_maker_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_goals_on_maker_group_id ON public.goals USING btree (maker_group_id);


--
-- Name: index_goals_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_goals_on_source ON public.goals USING btree (source) WHERE (source IS NOT NULL);


--
-- Name: index_goals_on_trending_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_goals_on_trending_at ON public.goals USING btree (trending_at) WHERE ((hidden_at IS NULL) AND (trending_at IS NOT NULL));


--
-- Name: index_goals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_goals_on_user_id ON public.goals USING btree (user_id);


--
-- Name: index_goals_on_user_id_and_current; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_goals_on_user_id_and_current ON public.goals USING btree (user_id, current) WHERE current;


--
-- Name: index_golden_kitty_categories_on_edition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_golden_kitty_categories_on_edition_id ON public.golden_kitty_categories USING btree (edition_id);


--
-- Name: index_golden_kitty_categories_on_slug_and_year; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_golden_kitty_categories_on_slug_and_year ON public.golden_kitty_categories USING btree (slug, year);


--
-- Name: index_golden_kitty_categories_on_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_golden_kitty_categories_on_topic_id ON public.golden_kitty_categories USING btree (topic_id);


--
-- Name: index_golden_kitty_categories_on_voting_enabled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_golden_kitty_categories_on_voting_enabled_at ON public.golden_kitty_categories USING btree (voting_enabled_at);


--
-- Name: index_golden_kitty_edition_sponsors_on_sponsor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_golden_kitty_edition_sponsors_on_sponsor_id ON public.golden_kitty_edition_sponsors USING btree (sponsor_id);


--
-- Name: index_golden_kitty_facts_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_golden_kitty_facts_on_category_id ON public.golden_kitty_facts USING btree (category_id);


--
-- Name: index_golden_kitty_finalists_on_golden_kitty_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_golden_kitty_finalists_on_golden_kitty_category_id ON public.golden_kitty_finalists USING btree (golden_kitty_category_id);


--
-- Name: index_golden_kitty_finalists_post_category; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_golden_kitty_finalists_post_category ON public.golden_kitty_finalists USING btree (post_id, golden_kitty_category_id);


--
-- Name: index_golden_kitty_nominees_on_golden_kitty_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_golden_kitty_nominees_on_golden_kitty_category_id ON public.golden_kitty_nominees USING btree (golden_kitty_category_id);


--
-- Name: index_golden_kitty_nominees_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_golden_kitty_nominees_on_user_id ON public.golden_kitty_nominees USING btree (user_id);


--
-- Name: index_golden_kitty_people_on_golden_kitty_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_golden_kitty_people_on_golden_kitty_category_id ON public.golden_kitty_people USING btree (golden_kitty_category_id);


--
-- Name: index_golden_kitty_people_on_user_id_and_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_golden_kitty_people_on_user_id_and_category_id ON public.golden_kitty_people USING btree (user_id, golden_kitty_category_id);


--
-- Name: index_highlighted_changes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_highlighted_changes_on_user_id ON public.highlighted_changes USING btree (user_id);


--
-- Name: index_house_keeper_broken_links_on_product_link_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_house_keeper_broken_links_on_product_link_id ON public.house_keeper_broken_links USING btree (product_link_id);


--
-- Name: index_input_suggestions_on_name_and_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_input_suggestions_on_name_and_kind ON public.input_suggestions USING btree (name, kind);


--
-- Name: index_input_suggestions_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_input_suggestions_on_parent_id ON public.input_suggestions USING btree (parent_id);


--
-- Name: index_iterable_event_webhook_data_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_iterable_event_webhook_data_on_email ON public.iterable_event_webhook_data USING btree (email);


--
-- Name: index_iterable_event_webhook_data_on_event_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_iterable_event_webhook_data_on_event_name ON public.iterable_event_webhook_data USING btree (event_name);


--
-- Name: index_jobs_discount_pages_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jobs_discount_pages_on_slug ON public.jobs_discount_pages USING btree (slug);


--
-- Name: index_jobs_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_email ON public.jobs USING btree (email);


--
-- Name: index_jobs_on_external_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_external_created_at ON public.jobs USING btree (external_created_at);


--
-- Name: index_jobs_on_jobs_discount_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_jobs_discount_page_id ON public.jobs USING btree (jobs_discount_page_id);


--
-- Name: index_jobs_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_kind ON public.jobs USING btree (kind);


--
-- Name: index_jobs_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_product_id ON public.jobs USING btree (product_id);


--
-- Name: index_jobs_on_published; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_published ON public.jobs USING btree (published);


--
-- Name: index_jobs_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jobs_on_slug ON public.jobs USING btree (slug);


--
-- Name: index_jobs_on_stripe_billing_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_stripe_billing_email ON public.jobs USING btree (stripe_billing_email) WHERE ((stripe_subscription_id IS NOT NULL) AND (cancelled_at IS NULL));


--
-- Name: index_jobs_on_stripe_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_stripe_customer_id ON public.jobs USING btree (stripe_customer_id);


--
-- Name: index_jobs_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_jobs_on_token ON public.jobs USING btree (token);


--
-- Name: index_jobs_on_trashed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_trashed_at ON public.jobs USING btree (trashed_at) WHERE (trashed_at IS NULL);


--
-- Name: index_jobs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_user_id ON public.jobs USING btree (user_id);


--
-- Name: index_kind_and_host_and_e_type_and_e_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_kind_and_host_and_e_type_and_e_id ON public.tracking_pixel_logs USING btree (kind, host, embeddable_type, embeddable_id);


--
-- Name: index_legacy_product_links_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_product_links_on_post_id ON public.legacy_product_links USING btree (post_id);


--
-- Name: index_legacy_product_links_on_primary_link_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_product_links_on_primary_link_and_post_id ON public.legacy_product_links USING btree (primary_link, post_id);


--
-- Name: index_legacy_product_links_on_product_id_and_primary_link; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_product_links_on_product_id_and_primary_link ON public.legacy_product_links USING btree (product_id, primary_link);


--
-- Name: index_legacy_product_links_on_short_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_legacy_product_links_on_short_code ON public.legacy_product_links USING btree (short_code);


--
-- Name: index_legacy_product_links_on_store_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_product_links_on_store_and_post_id ON public.legacy_product_links USING btree (store, post_id) WHERE (post_id IS NOT NULL);


--
-- Name: index_legacy_product_links_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_product_links_on_user_id ON public.legacy_product_links USING btree (user_id);


--
-- Name: index_legacy_products_on_angellist_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legacy_products_on_angellist_url ON public.legacy_products USING btree (angellist_url);


--
-- Name: index_link_spect_logs_on_external_link_and_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_link_spect_logs_on_external_link_and_expires_at ON public.link_spect_logs USING btree (external_link, expires_at);


--
-- Name: index_link_trackers_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_link_trackers_on_post_id ON public.link_trackers USING btree (post_id);


--
-- Name: index_link_trackers_on_track_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_link_trackers_on_track_code ON public.link_trackers USING btree (track_code);


--
-- Name: index_link_trackers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_link_trackers_on_user_id ON public.link_trackers USING btree (user_id);


--
-- Name: index_mailjet_stats_on_campaign_id_and_date; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mailjet_stats_on_campaign_id_and_date ON public.mailjet_stats USING btree (campaign_id, date);


--
-- Name: index_maker_activities_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_activities_on_created_at ON public.maker_activities USING btree (created_at);


--
-- Name: index_maker_activities_on_hidden_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_activities_on_hidden_at ON public.maker_activities USING btree (hidden_at);


--
-- Name: index_maker_activities_on_maker_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_activities_on_maker_group_id ON public.maker_activities USING btree (maker_group_id);


--
-- Name: index_maker_activities_on_subject_id_and_subject_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_activities_on_subject_id_and_subject_type ON public.maker_activities USING btree (subject_id, subject_type);


--
-- Name: index_maker_activities_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_activities_on_subject_type_and_subject_id ON public.maker_activities USING btree (subject_type, subject_id);


--
-- Name: index_maker_activities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_activities_on_user_id ON public.maker_activities USING btree (user_id);


--
-- Name: index_maker_fest_participants_on_upcoming_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_fest_participants_on_upcoming_page_id ON public.maker_fest_participants USING btree (upcoming_page_id);


--
-- Name: index_maker_fest_participants_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_fest_participants_on_user_id ON public.maker_fest_participants USING btree (user_id);


--
-- Name: index_maker_group_members_on_assessed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_group_members_on_assessed_at ON public.maker_group_members USING btree (assessed_at);


--
-- Name: index_maker_group_members_on_assessed_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_group_members_on_assessed_user_id ON public.maker_group_members USING btree (assessed_user_id);


--
-- Name: index_maker_group_members_on_last_activity_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_group_members_on_last_activity_at ON public.maker_group_members USING btree (last_activity_at);


--
-- Name: index_maker_group_members_on_maker_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_group_members_on_maker_group_id ON public.maker_group_members USING btree (maker_group_id);


--
-- Name: index_maker_group_members_on_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_group_members_on_role ON public.maker_group_members USING btree (role);


--
-- Name: index_maker_group_members_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_group_members_on_state ON public.maker_group_members USING btree (state);


--
-- Name: index_maker_group_members_on_user_id_and_maker_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_maker_group_members_on_user_id_and_maker_group_id ON public.maker_group_members USING btree (user_id, maker_group_id);


--
-- Name: index_maker_groups_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_groups_on_kind ON public.maker_groups USING btree (kind);


--
-- Name: index_maker_groups_on_last_activity_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_groups_on_last_activity_at ON public.maker_groups USING btree (last_activity_at);


--
-- Name: index_maker_reports_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_reports_on_post_id ON public.maker_reports USING btree (post_id);


--
-- Name: index_maker_reports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_reports_on_user_id ON public.maker_reports USING btree (user_id);


--
-- Name: index_maker_suggestions_on_approved_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_suggestions_on_approved_by_id ON public.maker_suggestions USING btree (approved_by_id);


--
-- Name: index_maker_suggestions_on_maker_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_suggestions_on_maker_id ON public.maker_suggestions USING btree (maker_id);


--
-- Name: index_maker_suggestions_on_post_id_and_maker_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_maker_suggestions_on_post_id_and_maker_id ON public.maker_suggestions USING btree (post_id, maker_id);


--
-- Name: index_maker_suggestions_on_post_id_and_maker_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_maker_suggestions_on_post_id_and_maker_username ON public.maker_suggestions USING btree (post_id, maker_username);


--
-- Name: index_maker_suggestions_on_product_maker_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maker_suggestions_on_product_maker_id ON public.maker_suggestions USING btree (product_maker_id);


--
-- Name: index_makers_festival_categories_on_edition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_makers_festival_categories_on_edition_id ON public.makers_festival_categories USING btree (makers_festival_edition_id);


--
-- Name: index_makers_festival_editions_on_maker_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_makers_festival_editions_on_maker_group_id ON public.makers_festival_editions USING btree (maker_group_id);


--
-- Name: index_makers_festival_editions_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_makers_festival_editions_on_slug ON public.makers_festival_editions USING btree (slug);


--
-- Name: index_makers_festival_editions_on_start_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_makers_festival_editions_on_start_date ON public.makers_festival_editions USING btree (start_date);


--
-- Name: index_makers_festival_makers_on_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_makers_festival_makers_on_participant_id ON public.makers_festival_makers USING btree (makers_festival_participant_id);


--
-- Name: index_makers_festival_makers_on_user_id_participant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_makers_festival_makers_on_user_id_participant_id ON public.makers_festival_makers USING btree (user_id, makers_festival_participant_id);


--
-- Name: index_makers_festival_participant_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_makers_festival_participant_on_category_id ON public.makers_festival_participants USING btree (makers_festival_category_id);


--
-- Name: index_makers_festival_participants_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_makers_festival_participants_on_user_id ON public.makers_festival_participants USING btree (user_id);


--
-- Name: index_marketing_notifications_on_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_marketing_notifications_on_sender_id ON public.marketing_notifications USING btree (sender_id);


--
-- Name: index_media_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_on_subject_type_and_subject_id ON public.media USING btree (subject_type, subject_id);


--
-- Name: index_media_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_media_on_user_id ON public.media USING btree (user_id);


--
-- Name: index_mentions_on_story_id_and_subject_id_and_subject_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mentions_on_story_id_and_subject_id_and_subject_type ON public.anthologies_story_mentions_associations USING btree (story_id, subject_id, subject_type);


--
-- Name: index_mentions_on_subject_id_and_subject_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mentions_on_subject_id_and_subject_type ON public.anthologies_story_mentions_associations USING btree (subject_type, subject_id);


--
-- Name: index_mentions_on_user_id_and_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mentions_on_user_id_and_subject_type_and_subject_id ON public.mentions USING btree (user_id, subject_type, subject_id);


--
-- Name: index_mobile_devices_on_user_id_and_device_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mobile_devices_on_user_id_and_device_uuid ON public.mobile_devices USING btree (user_id, device_uuid);


--
-- Name: index_moderation_duplicate_post_requests_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_duplicate_post_requests_on_post_id ON public.moderation_duplicate_post_requests USING btree (post_id);


--
-- Name: index_moderation_duplicate_post_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_duplicate_post_requests_on_user_id ON public.moderation_duplicate_post_requests USING btree (user_id);


--
-- Name: index_moderation_locks_on_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_moderation_locks_on_subject ON public.moderation_locks USING btree (subject_type, subject_id);


--
-- Name: index_moderation_locks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_locks_on_user_id ON public.moderation_locks USING btree (user_id);


--
-- Name: index_moderation_logs_on_reference_id_and_reference_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_logs_on_reference_id_and_reference_type ON public.moderation_logs USING btree (reference_id, reference_type);


--
-- Name: index_moderation_skips_on_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_skips_on_subject ON public.moderation_skips USING btree (subject_type, subject_id);


--
-- Name: index_moderation_skips_on_subject_and_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_moderation_skips_on_subject_and_user ON public.moderation_skips USING btree (subject_id, subject_type, user_id);


--
-- Name: index_moderation_skips_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_moderation_skips_on_user_id ON public.moderation_skips USING btree (user_id);


--
-- Name: index_multi_factor_tokens_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_multi_factor_tokens_on_user_id ON public.multi_factor_tokens USING btree (user_id);


--
-- Name: index_newsletter_events_on_newsletter_id_and_event_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletter_events_on_newsletter_id_and_event_name ON public.newsletter_events USING btree (newsletter_id, event_name);


--
-- Name: index_newsletter_events_on_newsletter_variant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletter_events_on_newsletter_variant_id ON public.newsletter_events USING btree (newsletter_variant_id);


--
-- Name: index_newsletter_events_on_subscriber_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletter_events_on_subscriber_id ON public.newsletter_events USING btree (subscriber_id);


--
-- Name: index_newsletter_experiments_on_newsletter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletter_experiments_on_newsletter_id ON public.newsletter_experiments USING btree (newsletter_id);


--
-- Name: index_newsletter_sponsors_on_newsletter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletter_sponsors_on_newsletter_id ON public.newsletter_sponsors USING btree (newsletter_id);


--
-- Name: index_newsletter_variants_on_newsletter_experiment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletter_variants_on_newsletter_experiment_id ON public.newsletter_variants USING btree (newsletter_experiment_id);


--
-- Name: index_newsletters_on_anthologies_story_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_newsletters_on_anthologies_story_id ON public.newsletters USING btree (anthologies_story_id);


--
-- Name: index_notification_events_on_notification_id_and_channel_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_events_on_notification_id_and_channel_name ON public.notification_events USING btree (notification_id, channel_name);


--
-- Name: index_notification_push_logs_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notification_push_logs_on_uuid ON public.notification_push_logs USING btree (uuid);


--
-- Name: index_notification_subscription_logs_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_subscription_logs_on_kind ON public.notification_subscription_logs USING btree (kind);


--
-- Name: index_notification_subscription_logs_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_subscription_logs_on_source ON public.notification_subscription_logs USING btree (source);


--
-- Name: index_notification_subscription_logs_on_subscriber_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_subscription_logs_on_subscriber_id ON public.notification_subscription_logs USING btree (subscriber_id);


--
-- Name: index_notification_unsubscription_logs_on_subscriber_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notification_unsubscription_logs_on_subscriber_id ON public.notification_unsubscription_logs USING btree (subscriber_id) WHERE ((notifyable_id IS NULL) AND (notifyable_type IS NULL));


--
-- Name: index_notifications_subscribers_on_browser_push_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notifications_subscribers_on_browser_push_token ON public.notifications_subscribers USING btree (browser_push_token);


--
-- Name: index_notifications_subscribers_on_desktop_push_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notifications_subscribers_on_desktop_push_token ON public.notifications_subscribers USING btree (desktop_push_token);


--
-- Name: index_notifications_subscribers_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notifications_subscribers_on_email ON public.notifications_subscribers USING btree (email);


--
-- Name: index_notifications_subscribers_on_hashed_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_subscribers_on_hashed_email ON public.notifications_subscribers USING btree (md5(lower((email)::text)));


--
-- Name: index_notifications_subscribers_on_mobile_push_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notifications_subscribers_on_mobile_push_token ON public.notifications_subscribers USING btree (mobile_push_token);


--
-- Name: index_notifications_subscribers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notifications_subscribers_on_user_id ON public.notifications_subscribers USING btree (user_id);


--
-- Name: index_notifications_subscribers_on_verification_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notifications_subscribers_on_verification_token ON public.notifications_subscribers USING btree (verification_token);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id_x; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id_x ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id_x; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id_x ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_legacy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_legacy ON public.oauth_applications USING btree (legacy);


--
-- Name: index_oauth_applications_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_owner_id_and_owner_type ON public.oauth_applications USING btree (owner_id, owner_type);


--
-- Name: index_oauth_applications_on_twitter_app_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_twitter_app_name ON public.oauth_applications USING btree (twitter_app_name);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_oauth_requests_application_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_requests_application_id_user_id ON public.oauth_requests USING btree (application_id, user_id);


--
-- Name: index_oauth_requests_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_requests_on_application_id ON public.oauth_requests USING btree (application_id) WHERE (user_id IS NULL);


--
-- Name: index_on_upcoming_event_query_columns; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_on_upcoming_event_query_columns ON public.upcoming_events USING btree (product_id, post_id, active, status);


--
-- Name: index_onboarding_reasons_on_user_id_and_reason; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_onboarding_reasons_on_user_id_and_reason ON public.onboarding_reasons USING btree (user_id, reason);


--
-- Name: index_onboarding_tasks_on_user_id_and_task; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_onboarding_tasks_on_user_id_and_task ON public.onboarding_tasks USING btree (user_id, task);


--
-- Name: index_onboardings_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_onboardings_on_status ON public.onboardings USING btree (status);


--
-- Name: index_onboardings_on_user_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_onboardings_on_user_id_and_name ON public.onboardings USING btree (user_id, name);


--
-- Name: index_page_contents_on_page_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_page_contents_on_page_key ON public.page_contents USING btree (page_key);


--
-- Name: index_payment_card_update_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_card_update_logs_on_user_id ON public.payment_card_update_logs USING btree (user_id);


--
-- Name: index_payment_discounts_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_discounts_on_active ON public.payment_discounts USING btree (active) WHERE (active IS TRUE);


--
-- Name: index_payment_discounts_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_payment_discounts_on_code ON public.payment_discounts USING btree (code);


--
-- Name: index_payment_discounts_on_stripe_coupon_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_payment_discounts_on_stripe_coupon_code ON public.payment_discounts USING btree (stripe_coupon_code);


--
-- Name: index_payment_plan_discount_associations_on_discount_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_plan_discount_associations_on_discount_id ON public.payment_plan_discount_associations USING btree (discount_id);


--
-- Name: index_payment_plan_discount_associations_on_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_plan_discount_associations_on_plan_id ON public.payment_plan_discount_associations USING btree (plan_id);


--
-- Name: index_payment_plans_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_plans_on_active ON public.payment_plans USING btree (active) WHERE (active IS TRUE);


--
-- Name: index_payment_plans_on_project; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_plans_on_project ON public.payment_plans USING btree (project);


--
-- Name: index_payment_plans_on_stripe_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_payment_plans_on_stripe_plan_id ON public.payment_plans USING btree (stripe_plan_id);


--
-- Name: index_payment_subscriptions_on_discount_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_subscriptions_on_discount_id ON public.payment_subscriptions USING btree (discount_id);


--
-- Name: index_payment_subscriptions_on_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_subscriptions_on_plan_id ON public.payment_subscriptions USING btree (plan_id);


--
-- Name: index_payment_subscriptions_on_project; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_subscriptions_on_project ON public.payment_subscriptions USING btree (project);


--
-- Name: index_payment_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_subscriptions_on_user_id ON public.payment_subscriptions USING btree (user_id);


--
-- Name: index_payment_subscriptions_project_user_expired_at_refunded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_subscriptions_project_user_expired_at_refunded_at ON public.payment_subscriptions USING btree (project, user_id, expired_at, refunded_at) WHERE ((expired_at IS NULL) AND (refunded_at IS NULL));


--
-- Name: index_payment_subscriptions_stripe_customer_id_subscription_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payment_subscriptions_stripe_customer_id_subscription_id ON public.payment_subscriptions USING btree (stripe_customer_id, stripe_subscription_id);


--
-- Name: index_pghero_query_stats_on_database_and_captured_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pghero_query_stats_on_database_and_captured_at ON public.pghero_query_stats USING btree (database, captured_at);


--
-- Name: index_poll_answers_on_poll_option_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_poll_answers_on_poll_option_id_and_user_id ON public.poll_answers USING btree (poll_option_id, user_id);


--
-- Name: index_poll_answers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_poll_answers_on_user_id ON public.poll_answers USING btree (user_id);


--
-- Name: index_poll_options_on_poll_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_poll_options_on_poll_id ON public.poll_options USING btree (poll_id);


--
-- Name: index_polls_on_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_polls_on_subject ON public.polls USING btree (subject_type, subject_id);


--
-- Name: index_post_drafts_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_drafts_on_post_id ON public.post_drafts USING btree (post_id);


--
-- Name: index_post_drafts_on_suggested_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_drafts_on_suggested_product_id ON public.post_drafts USING btree (suggested_product_id);


--
-- Name: index_post_drafts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_drafts_on_user_id ON public.post_drafts USING btree (user_id);


--
-- Name: index_post_drafts_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_post_drafts_on_uuid ON public.post_drafts USING btree (uuid);


--
-- Name: index_post_topic_associations_on_post_id_and_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_post_topic_associations_on_post_id_and_topic_id ON public.post_topic_associations USING btree (post_id, topic_id);


--
-- Name: index_post_topic_associations_on_topic_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_topic_associations_on_topic_id_and_post_id ON public.post_topic_associations USING btree (topic_id, post_id);


--
-- Name: index_posts_launch_day_reports_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_launch_day_reports_on_post_id ON public.posts_launch_day_reports USING btree (post_id);


--
-- Name: index_posts_on_comments_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_comments_count ON public.posts USING btree (comments_count);


--
-- Name: index_posts_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_created_at ON public.posts USING btree (created_at) WHERE (trashed_at IS NULL);


--
-- Name: index_posts_on_credible_votes_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_credible_votes_count ON public.posts USING btree (credible_votes_count);


--
-- Name: index_posts_on_featured_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_featured_at ON public.posts USING btree (featured_at) WHERE (trashed_at IS NULL);


--
-- Name: index_posts_on_featured_at_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_featured_at_scheduled_at ON public.posts USING btree (featured_at, scheduled_at);


--
-- Name: index_posts_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_name_trgm ON public.posts USING gin (COALESCE((name)::text, ''::text) public.gin_trgm_ops);


--
-- Name: index_posts_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_product_id ON public.posts USING btree (product_id);


--
-- Name: index_posts_on_product_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_product_state ON public.posts USING btree (product_state);


--
-- Name: index_posts_on_scheduled_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_scheduled_at ON public.posts USING btree (scheduled_at);


--
-- Name: index_posts_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_posts_on_slug ON public.posts USING btree (slug);


--
-- Name: index_posts_on_trashed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_trashed_at ON public.posts USING btree (trashed_at);


--
-- Name: index_product_activities_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_product_activities_unique ON public.product_activity_events USING btree (product_id, subject_type, subject_id);


--
-- Name: index_product_activity_events_on_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_activity_events_on_subject ON public.product_activity_events USING btree (subject_type, subject_id);


--
-- Name: index_product_alternative_suggestions_on_alternative_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_alternative_suggestions_on_alternative_product_id ON public.product_alternative_suggestions USING btree (alternative_product_id);


--
-- Name: index_product_alternative_suggestions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_alternative_suggestions_on_user_id ON public.product_alternative_suggestions USING btree (user_id);


--
-- Name: index_product_associations_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_product_associations_unique ON public.product_associations USING btree (product_id, associated_product_id);


--
-- Name: index_product_categories_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_categories_on_parent_id ON public.product_categories USING btree (parent_id);


--
-- Name: index_product_category_associations_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_category_associations_on_category_id ON public.product_category_associations USING btree (category_id);


--
-- Name: index_product_category_associations_on_product_and_category; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_product_category_associations_on_product_and_category ON public.product_category_associations USING btree (product_id, category_id);


--
-- Name: index_product_links_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_links_on_product_id ON public.product_links USING btree (product_id);


--
-- Name: index_product_links_on_url; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_links_on_url ON public.product_links USING btree (url);


--
-- Name: index_product_makers_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_makers_on_post_id ON public.product_makers USING btree (post_id);


--
-- Name: index_product_makers_on_user_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_product_makers_on_user_id_and_post_id ON public.product_makers USING btree (user_id, post_id);


--
-- Name: index_product_post_associations_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_product_post_associations_on_post_id ON public.product_post_associations USING btree (post_id);


--
-- Name: index_product_post_associations_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_post_associations_on_product_id ON public.product_post_associations USING btree (product_id);


--
-- Name: index_product_requests_on_comments_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_requests_on_comments_count ON public.product_requests USING btree (comments_count);


--
-- Name: index_product_requests_on_duplicate_of_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_requests_on_duplicate_of_id ON public.product_requests USING btree (duplicate_of_id);


--
-- Name: index_product_requests_on_featured_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_requests_on_featured_at ON public.product_requests USING btree (featured_at);


--
-- Name: index_product_requests_on_followers_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_requests_on_followers_count ON public.product_requests USING btree (followers_count);


--
-- Name: index_product_requests_on_hidden_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_requests_on_hidden_at ON public.product_requests USING btree (hidden_at);


--
-- Name: index_product_requests_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_requests_on_kind ON public.product_requests USING btree (kind);


--
-- Name: index_product_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_requests_on_user_id ON public.product_requests USING btree (user_id);


--
-- Name: index_product_review_summaries_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_review_summaries_on_product_id ON public.product_review_summaries USING btree (product_id);


--
-- Name: index_product_review_summaries_to_reviews; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_review_summaries_to_reviews ON public.product_review_summary_associations USING btree (product_review_summary_id, review_id);


--
-- Name: index_product_scrape_results_on_product_id_and_source; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_product_scrape_results_on_product_id_and_source ON public.product_scrape_results USING btree (product_id, source);


--
-- Name: index_product_screenshots_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_screenshots_on_product_id ON public.product_screenshots USING btree (product_id);


--
-- Name: index_product_screenshots_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_screenshots_on_user_id ON public.product_screenshots USING btree (user_id);


--
-- Name: index_product_stacks_on_product_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_product_stacks_on_product_id_and_user_id ON public.product_stacks USING btree (product_id, user_id);


--
-- Name: index_product_stacks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_stacks_on_user_id ON public.product_stacks USING btree (user_id);


--
-- Name: index_product_topic_associations_on_product_id_and_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_product_topic_associations_on_product_id_and_topic_id ON public.product_topic_associations USING btree (product_id, topic_id);


--
-- Name: index_product_topic_associations_on_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_product_topic_associations_on_topic_id ON public.product_topic_associations USING btree (topic_id);


--
-- Name: index_products_on_addons_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_addons_count ON public.products USING btree (addons_count);


--
-- Name: index_products_on_clean_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_products_on_clean_url ON public.products USING btree (clean_url);


--
-- Name: index_products_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_created_at ON public.products USING btree (created_at);


--
-- Name: index_products_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_products_on_slug ON public.products USING btree (slug);


--
-- Name: index_products_on_trashed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_on_trashed_at ON public.products USING btree (trashed_at);


--
-- Name: index_products_on_website_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_products_on_website_url ON public.products USING btree (website_url);


--
-- Name: index_products_skip_review_suggestions_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_products_skip_review_suggestions_on_product_id ON public.products_skip_review_suggestions USING btree (product_id);


--
-- Name: index_promoted_analytics_on_promoted_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promoted_analytics_on_promoted_product_id ON public.promoted_analytics USING btree (promoted_product_id);


--
-- Name: index_promoted_analytics_on_track_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promoted_analytics_on_track_code ON public.promoted_analytics USING btree (track_code);


--
-- Name: index_promoted_analytics_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promoted_analytics_on_user_id ON public.promoted_analytics USING btree (user_id);


--
-- Name: index_promoted_email_ab_variants_on_ab_test_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promoted_email_ab_variants_on_ab_test_id ON public.promoted_email_ab_test_variants USING btree (promoted_email_ab_test_id);


--
-- Name: index_promoted_email_campaigns_on_ab_test_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promoted_email_campaigns_on_ab_test_id ON public.promoted_email_campaigns USING btree (promoted_email_ab_test_id) WHERE (promoted_email_ab_test_id IS NOT NULL);


--
-- Name: index_promoted_email_campaigns_on_campaign_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promoted_email_campaigns_on_campaign_name ON public.promoted_email_campaigns USING btree (campaign_name) WHERE (campaign_name IS NOT NULL);


--
-- Name: index_promoted_email_email_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_promoted_email_email_campaign_id ON public.promoted_email_signups USING btree (email, promoted_email_campaign_id);


--
-- Name: index_promoted_email_signups_on_promoted_email_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promoted_email_signups_on_promoted_email_campaign_id ON public.promoted_email_signups USING btree (promoted_email_campaign_id);


--
-- Name: index_promoted_email_user_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_promoted_email_user_campaign_id ON public.promoted_email_signups USING btree (user_id, promoted_email_campaign_id) WHERE (user_id IS NOT NULL);


--
-- Name: index_promoted_products_on_newsletter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_promoted_products_on_newsletter_id ON public.promoted_products USING btree (newsletter_id);


--
-- Name: index_promoted_products_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promoted_products_on_post_id ON public.promoted_products USING btree (post_id);


--
-- Name: index_promoted_products_on_promoted_product_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promoted_products_on_promoted_product_campaign_id ON public.promoted_products USING btree (promoted_product_campaign_id);


--
-- Name: index_promoted_products_on_promoted_type_and_topic_bundle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promoted_products_on_promoted_type_and_topic_bundle ON public.promoted_products USING btree (promoted_type, topic_bundle) WHERE (topic_bundle IS NOT NULL);


--
-- Name: index_promoted_products_on_trashed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_promoted_products_on_trashed_at ON public.promoted_products USING btree (trashed_at) WHERE (trashed_at IS NULL);


--
-- Name: index_published_change_logs_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_published_change_logs_date ON public.change_log_entries USING btree (date) WHERE ((state)::text = 'published'::text);


--
-- Name: index_questions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questions_on_post_id ON public.questions USING btree (post_id);


--
-- Name: index_questions_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_questions_on_slug ON public.questions USING btree (slug);


--
-- Name: index_radio_sponsors_on_start_datetime_and_end_datetime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_radio_sponsors_on_start_datetime_and_end_datetime ON public.radio_sponsors USING btree (start_datetime, end_datetime);


--
-- Name: index_recommendations_on_comments_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recommendations_on_comments_count ON public.recommendations USING btree (comments_count);


--
-- Name: index_recommendations_on_credible_votes_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recommendations_on_credible_votes_count ON public.recommendations USING btree (credible_votes_count);


--
-- Name: index_recommendations_on_recommended_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recommendations_on_recommended_product_id ON public.recommendations USING btree (recommended_product_id);


--
-- Name: index_recommendations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recommendations_on_user_id ON public.recommendations USING btree (user_id);


--
-- Name: index_recommended_products_on_credible_votes_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recommended_products_on_credible_votes_count ON public.recommended_products USING btree (credible_votes_count);


--
-- Name: index_recommended_products_on_new_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recommended_products_on_new_product_id ON public.recommended_products USING btree (new_product_id);


--
-- Name: index_related_product_requests_on_product_requests; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_related_product_requests_on_product_requests ON public.product_request_related_product_request_associations USING btree (product_request_id, related_product_request_id);


--
-- Name: index_related_product_requests_on_related_product_request; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_product_requests_on_related_product_request ON public.product_request_related_product_request_associations USING btree (related_product_request_id);


--
-- Name: index_review_tag_associations_on_join; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_review_tag_associations_on_join ON public.review_tag_associations USING btree (review_id, review_tag_id, sentiment);


--
-- Name: index_review_tag_associations_on_review_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_review_tag_associations_on_review_tag_id ON public.review_tag_associations USING btree (review_tag_id);


--
-- Name: index_review_tags_on_property; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_review_tags_on_property ON public.review_tags USING btree (property);


--
-- Name: index_reviews_on_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_comment_id ON public.reviews USING btree (comment_id);


--
-- Name: index_reviews_on_credible_votes_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_credible_votes_count ON public.reviews USING btree (credible_votes_count);


--
-- Name: index_reviews_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_post_id ON public.reviews USING btree (post_id);


--
-- Name: index_reviews_on_product_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_product_id_and_user_id ON public.reviews USING btree (product_id, user_id);


--
-- Name: index_reviews_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_user_id ON public.reviews USING btree (user_id);


--
-- Name: index_reviews_on_votes_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_votes_count ON public.reviews USING btree (votes_count);


--
-- Name: index_reviews_to_product_review_summaries; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_to_product_review_summaries ON public.product_review_summary_associations USING btree (review_id, product_review_summary_id);


--
-- Name: index_search_user_searches_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_search_user_searches_on_created_at ON public.search_user_searches USING btree (created_at);


--
-- Name: index_search_user_searches_on_search_type_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_search_user_searches_on_search_type_and_created_at ON public.search_user_searches USING btree (search_type, created_at);


--
-- Name: index_search_user_searches_on_search_type_query; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_search_user_searches_on_search_type_query ON public.search_user_searches USING btree (search_type, normalized_query, created_at);


--
-- Name: index_search_user_searches_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_search_user_searches_on_user_id ON public.search_user_searches USING btree (user_id);


--
-- Name: index_seo_queries_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_seo_queries_on_subject_type_and_subject_id ON public.seo_queries USING btree (subject_type, subject_id);


--
-- Name: index_seo_structured_data_validaton_on_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_seo_structured_data_validaton_on_subject ON public.seo_structured_data_validation_messages USING btree (subject_type, subject_id);


--
-- Name: index_ship_account_member_associations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_account_member_associations_on_user_id ON public.ship_account_member_associations USING btree (user_id);


--
-- Name: index_ship_accounts_on_ship_subscription_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ship_accounts_on_ship_subscription_id ON public.ship_accounts USING btree (ship_subscription_id);


--
-- Name: index_ship_accounts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ship_accounts_on_user_id ON public.ship_accounts USING btree (user_id);


--
-- Name: index_ship_aws_applications_on_ship_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_aws_applications_on_ship_account_id ON public.ship_aws_applications USING btree (ship_account_id);


--
-- Name: index_ship_billing_informations_on_stripe_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ship_billing_informations_on_stripe_customer_id ON public.ship_billing_informations USING btree (stripe_customer_id);


--
-- Name: index_ship_billing_informations_on_stripe_token_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ship_billing_informations_on_stripe_token_id ON public.ship_billing_informations USING btree (stripe_token_id);


--
-- Name: index_ship_billing_informations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ship_billing_informations_on_user_id ON public.ship_billing_informations USING btree (user_id);


--
-- Name: index_ship_cancellation_reasons_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_cancellation_reasons_on_user_id ON public.ship_cancellation_reasons USING btree (user_id);


--
-- Name: index_ship_contacts_on_clearbit_person_profile_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_contacts_on_clearbit_person_profile_id ON public.ship_contacts USING btree (clearbit_person_profile_id);


--
-- Name: index_ship_contacts_on_email_and_email_confirmed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_contacts_on_email_and_email_confirmed ON public.ship_contacts USING btree (email, email_confirmed);


--
-- Name: index_ship_contacts_on_ship_account_id_and_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ship_contacts_on_ship_account_id_and_email ON public.ship_contacts USING btree (ship_account_id, email);


--
-- Name: index_ship_contacts_on_ship_account_id_and_trashed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_contacts_on_ship_account_id_and_trashed_at ON public.ship_contacts USING btree (ship_account_id, trashed_at);


--
-- Name: index_ship_contacts_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ship_contacts_on_token ON public.ship_contacts USING btree (token);


--
-- Name: index_ship_contacts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_contacts_on_user_id ON public.ship_contacts USING btree (user_id);


--
-- Name: index_ship_instant_access_pages_on_ship_invite_code_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_instant_access_pages_on_ship_invite_code_id ON public.ship_instant_access_pages USING btree (ship_invite_code_id);


--
-- Name: index_ship_leads_on_ship_instant_access_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_leads_on_ship_instant_access_page_id ON public.ship_leads USING btree (ship_instant_access_page_id);


--
-- Name: index_ship_leads_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_leads_on_user_id ON public.ship_leads USING btree (user_id);


--
-- Name: index_ship_stripe_applications_on_ship_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_stripe_applications_on_ship_account_id ON public.ship_stripe_applications USING btree (ship_account_id);


--
-- Name: index_ship_subscriptions_on_user_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_subscriptions_on_user_id_and_status ON public.ship_subscriptions USING btree (user_id, status);


--
-- Name: index_ship_tracking_events_on_funnel_step; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_tracking_events_on_funnel_step ON public.ship_tracking_events USING btree (funnel_step);


--
-- Name: index_ship_tracking_events_on_ship_tracking_identity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_tracking_events_on_ship_tracking_identity_id ON public.ship_tracking_events USING btree (ship_tracking_identity_id);


--
-- Name: index_ship_tracking_identities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_tracking_identities_on_user_id ON public.ship_tracking_identities USING btree (user_id);


--
-- Name: index_ship_tracking_identities_on_visitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ship_tracking_identities_on_visitor_id ON public.ship_tracking_identities USING btree (visitor_id);


--
-- Name: index_ship_user_metadata_on_ship_instant_access_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ship_user_metadata_on_ship_instant_access_page_id ON public.ship_user_metadata USING btree (ship_instant_access_page_id);


--
-- Name: index_ship_user_metadata_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ship_user_metadata_on_user_id ON public.ship_user_metadata USING btree (user_id);


--
-- Name: index_shoutouts_on_trashed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shoutouts_on_trashed_at ON public.shoutouts USING btree (trashed_at);


--
-- Name: index_shoutouts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shoutouts_on_user_id ON public.shoutouts USING btree (user_id);


--
-- Name: index_similar_coll_associations_on_coll_id_and_similar_coll_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_similar_coll_associations_on_coll_id_and_similar_coll_id ON public.similar_collection_associations USING btree (collection_id, similar_collection_id);


--
-- Name: index_skip_review_suggestions_on_user_and_product; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_skip_review_suggestions_on_user_and_product ON public.products_skip_review_suggestions USING btree (user_id, product_id);


--
-- Name: index_spam_action_logs_on_reverted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_action_logs_on_reverted_by_id ON public.spam_action_logs USING btree (reverted_by_id);


--
-- Name: index_spam_action_logs_on_spam_ruleset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_action_logs_on_spam_ruleset_id ON public.spam_action_logs USING btree (spam_ruleset_id);


--
-- Name: index_spam_action_logs_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_action_logs_on_subject_type_and_subject_id ON public.spam_action_logs USING btree (subject_type, subject_id);


--
-- Name: index_spam_action_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_action_logs_on_user_id ON public.spam_action_logs USING btree (user_id);


--
-- Name: index_spam_filter_values_on_added_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_filter_values_on_added_by_id ON public.spam_filter_values USING btree (added_by_id);


--
-- Name: index_spam_filter_values_on_value_and_filter_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_spam_filter_values_on_value_and_filter_kind ON public.spam_filter_values USING btree (value, filter_kind);


--
-- Name: index_spam_logs_on_content_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_logs_on_content_type ON public.spam_logs USING btree (content_type);


--
-- Name: index_spam_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_logs_on_user_id ON public.spam_logs USING btree (user_id);


--
-- Name: index_spam_manual_logs_on_activity_type_and_activity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_manual_logs_on_activity_type_and_activity_id ON public.spam_manual_logs USING btree (activity_type, activity_id);


--
-- Name: index_spam_manual_logs_on_handled_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_manual_logs_on_handled_by_id ON public.spam_manual_logs USING btree (handled_by_id);


--
-- Name: index_spam_manual_logs_on_reverted_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_manual_logs_on_reverted_by_id ON public.spam_manual_logs USING btree (reverted_by_id);


--
-- Name: index_spam_manual_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_manual_logs_on_user_id ON public.spam_manual_logs USING btree (user_id);


--
-- Name: index_spam_multiple_accounts_logs_on_current_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_multiple_accounts_logs_on_current_user_id ON public.spam_multiple_accounts_logs USING btree (current_user_id);


--
-- Name: index_spam_multiple_accounts_logs_on_previous_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_multiple_accounts_logs_on_previous_user_id ON public.spam_multiple_accounts_logs USING btree (previous_user_id);


--
-- Name: index_spam_reports_on_handled_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_reports_on_handled_by_id ON public.spam_reports USING btree (handled_by_id);


--
-- Name: index_spam_reports_on_spam_action_log_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_reports_on_spam_action_log_id ON public.spam_reports USING btree (spam_action_log_id);


--
-- Name: index_spam_reports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_reports_on_user_id ON public.spam_reports USING btree (user_id);


--
-- Name: index_spam_rule_logs_on_spam_action_log_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_rule_logs_on_spam_action_log_id ON public.spam_rule_logs USING btree (spam_action_log_id);


--
-- Name: index_spam_rule_logs_on_spam_filter_value_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_rule_logs_on_spam_filter_value_id ON public.spam_rule_logs USING btree (spam_filter_value_id);


--
-- Name: index_spam_rule_logs_on_spam_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_rule_logs_on_spam_rule_id ON public.spam_rule_logs USING btree (spam_rule_id);


--
-- Name: index_spam_rule_logs_on_spam_ruleset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_rule_logs_on_spam_ruleset_id ON public.spam_rule_logs USING btree (spam_ruleset_id);


--
-- Name: index_spam_rules_on_spam_ruleset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_rules_on_spam_ruleset_id ON public.spam_rules USING btree (spam_ruleset_id);


--
-- Name: index_spam_rules_on_value_and_filter_kind_and_spam_ruleset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_spam_rules_on_value_and_filter_kind_and_spam_ruleset_id ON public.spam_rules USING btree (value, filter_kind, spam_ruleset_id);


--
-- Name: index_spam_rulesets_on_added_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_rulesets_on_added_by_id ON public.spam_rulesets USING btree (added_by_id);


--
-- Name: index_spam_rulesets_on_for_activity_and_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_spam_rulesets_on_for_activity_and_active ON public.spam_rulesets USING btree (for_activity, active);


--
-- Name: index_stream_events_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stream_events_on_name ON public.stream_events USING btree (name);


--
-- Name: index_stream_events_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stream_events_on_subject_type_and_subject_id ON public.stream_events USING btree (subject_type, subject_id);


--
-- Name: index_stream_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stream_events_on_user_id ON public.stream_events USING btree (user_id);


--
-- Name: index_stream_feed_items_on_action_objects; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stream_feed_items_on_action_objects ON public.stream_feed_items USING gin (action_objects);


--
-- Name: index_stream_feed_items_on_last_occurrence_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stream_feed_items_on_last_occurrence_at ON public.stream_feed_items USING btree (last_occurrence_at);


--
-- Name: index_stream_feed_items_on_receiver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stream_feed_items_on_receiver_id ON public.stream_feed_items USING btree (receiver_id);


--
-- Name: index_stream_feed_items_on_seen_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stream_feed_items_on_seen_at ON public.stream_feed_items USING btree (seen_at);


--
-- Name: index_stream_feed_items_on_target_type_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stream_feed_items_on_target_type_and_target_id ON public.stream_feed_items USING btree (target_type, target_id);


--
-- Name: index_stream_feed_items_on_verb; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stream_feed_items_on_verb ON public.stream_feed_items USING btree (verb);


--
-- Name: index_subject_media_modifications_on_subject_column; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subject_media_modifications_on_subject_column ON public.subject_media_modifications USING btree (subject_column);


--
-- Name: index_subject_media_modifications_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subject_media_modifications_on_subject_id ON public.subject_media_modifications USING btree (subject_id);


--
-- Name: index_subject_media_modifications_on_subject_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subject_media_modifications_on_subject_type ON public.subject_media_modifications USING btree (subject_type);


--
-- Name: index_subscriber_id_question_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriber_id_question_option_id ON public.upcoming_page_question_answers USING btree (upcoming_page_subscriber_id, upcoming_page_question_option_id);


--
-- Name: index_subscriptions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_created_at ON public.subscriptions USING btree (created_at);


--
-- Name: index_subscriptions_on_subject_and_subscriber; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subscriptions_on_subject_and_subscriber ON public.subscriptions USING btree (state, subject_type, subject_id, subscriber_id);


--
-- Name: index_subscriptions_on_subject_and_subscriber_reverse; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subscriptions_on_subject_and_subscriber_reverse ON public.subscriptions USING btree (state, subject_type, subscriber_id, subject_id);


--
-- Name: index_subscriptions_on_subject_id_and_subject_type_and_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_subject_id_and_subject_type_and_state ON public.subscriptions USING btree (subject_id, subject_type, state);


--
-- Name: index_subscriptions_on_subject_type_and_subscriber_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_subject_type_and_subscriber_id ON public.subscriptions USING btree (subject_type, subscriber_id);


--
-- Name: index_subscriptions_on_subscriber_id_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subscriptions_on_subscriber_id_and_subject_id ON public.subscriptions USING btree (subscriber_id, subject_id);


--
-- Name: index_team_invites_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_invites_on_code ON public.team_invites USING btree (code);


--
-- Name: index_team_invites_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_invites_on_product_id ON public.team_invites USING btree (product_id);


--
-- Name: index_team_invites_on_referrer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_invites_on_referrer_id ON public.team_invites USING btree (referrer_id);


--
-- Name: index_team_invites_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_invites_on_user_id ON public.team_invites USING btree (user_id);


--
-- Name: index_team_members_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_members_on_product_id ON public.team_members USING btree (product_id);


--
-- Name: index_team_members_on_referrer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_members_on_referrer ON public.team_members USING btree (referrer_type, referrer_id);


--
-- Name: index_team_members_on_user_id_and_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_team_members_on_user_id_and_product_id ON public.team_members USING btree (user_id, product_id);


--
-- Name: index_team_requests_on_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_requests_on_product_id ON public.team_requests USING btree (product_id);


--
-- Name: index_team_requests_on_status_changed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_requests_on_status_changed_by_id ON public.team_requests USING btree (status_changed_by_id);


--
-- Name: index_team_requests_on_team_email_confirmed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_requests_on_team_email_confirmed ON public.team_requests USING btree (team_email_confirmed);


--
-- Name: index_team_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_requests_on_user_id ON public.team_requests USING btree (user_id);


--
-- Name: index_team_requests_on_verification_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_requests_on_verification_token ON public.team_requests USING btree (verification_token);


--
-- Name: index_topic_aliases_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_topic_aliases_on_name ON public.topic_aliases USING gin (name public.gin_trgm_ops);


--
-- Name: index_topic_aliases_on_name_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_topic_aliases_on_name_unique ON public.topic_aliases USING btree (name);


--
-- Name: index_topic_user_associations_on_topic_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_topic_user_associations_on_topic_id_and_user_id ON public.topic_user_associations USING btree (topic_id, user_id);


--
-- Name: index_topic_user_associations_on_user_id_and_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_topic_user_associations_on_user_id_and_topic_id ON public.topic_user_associations USING btree (user_id, topic_id);


--
-- Name: index_topics_on_lower(name); Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "index_topics_on_lower(name)" ON public.topics USING btree (lower((name)::text));


--
-- Name: index_topics_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_topics_on_parent_id ON public.topics USING btree (parent_id);


--
-- Name: index_topics_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_topics_on_slug ON public.topics USING btree (slug);


--
-- Name: index_tracking_pixel_logs_on_embeddable_type_and_embeddable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tracking_pixel_logs_on_embeddable_type_and_embeddable_id ON public.tracking_pixel_logs USING btree (embeddable_type, embeddable_id);


--
-- Name: index_twitter_follower_counts_on_subject_and_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_twitter_follower_counts_on_subject_and_id ON public.twitter_follower_counts USING btree (subject_id, subject_type);


--
-- Name: index_twitter_verified_users_on_twitter_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_twitter_verified_users_on_twitter_uid ON public.twitter_verified_users USING btree (twitter_uid);


--
-- Name: index_u_p_conversation_messages_on_u_p_conversation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_u_p_conversation_messages_on_u_p_conversation_id ON public.upcoming_page_conversation_messages USING btree (upcoming_page_conversation_id);


--
-- Name: index_u_p_conversation_messages_on_u_p_email_reply_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_u_p_conversation_messages_on_u_p_email_reply_id ON public.upcoming_page_conversation_messages USING btree (upcoming_page_email_reply_id);


--
-- Name: index_u_p_conversation_messages_on_u_p_sub_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_u_p_conversation_messages_on_u_p_sub_id ON public.upcoming_page_conversation_messages USING btree (upcoming_page_subscriber_id);


--
-- Name: index_u_p_m_deliveries_on_subject_and_subscriber; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_u_p_m_deliveries_on_subject_and_subscriber ON public.upcoming_page_message_deliveries USING btree (subject_type, subject_id, upcoming_page_subscriber_id);


--
-- Name: index_upcoming_events_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_upcoming_events_on_post_id ON public.upcoming_events USING btree (post_id);


--
-- Name: index_upcoming_events_on_product_id_and_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_upcoming_events_on_product_id_and_active ON public.upcoming_events USING btree (product_id, active) WHERE (active = true);


--
-- Name: index_upcoming_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_events_on_user_id ON public.upcoming_events USING btree (user_id);


--
-- Name: index_upcoming_page_conversation_messages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_conversation_messages_on_user_id ON public.upcoming_page_conversation_messages USING btree (user_id);


--
-- Name: index_upcoming_page_conversations_on_trashed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_conversations_on_trashed_at ON public.upcoming_page_conversations USING btree (trashed_at);


--
-- Name: index_upcoming_page_conversations_on_upcoming_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_conversations_on_upcoming_page_id ON public.upcoming_page_conversations USING btree (upcoming_page_id);


--
-- Name: index_upcoming_page_conversations_on_upcoming_page_message_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_conversations_on_upcoming_page_message_id ON public.upcoming_page_conversations USING btree (upcoming_page_message_id);


--
-- Name: index_upcoming_page_email_imports_on_upcoming_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_email_imports_on_upcoming_page_id ON public.upcoming_page_email_imports USING btree (upcoming_page_id);


--
-- Name: index_upcoming_page_links_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_links_on_kind ON public.upcoming_page_links USING btree (kind);


--
-- Name: index_upcoming_page_links_on_upcoming_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_links_on_upcoming_page_id ON public.upcoming_page_links USING btree (upcoming_page_id);


--
-- Name: index_upcoming_page_maker_tasks_on_completed_by_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_maker_tasks_on_completed_by_user_id ON public.upcoming_page_maker_tasks USING btree (completed_by_user_id);


--
-- Name: index_upcoming_page_maker_tasks_on_upcoming_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_maker_tasks_on_upcoming_page_id ON public.upcoming_page_maker_tasks USING btree (upcoming_page_id);


--
-- Name: index_upcoming_page_message_deliveries_on_message_subscriber; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_upcoming_page_message_deliveries_on_message_subscriber ON public.upcoming_page_message_deliveries USING btree (upcoming_page_message_id, upcoming_page_subscriber_id);


--
-- Name: index_upcoming_page_message_deliveries_on_subscriber_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_message_deliveries_on_subscriber_id ON public.upcoming_page_message_deliveries USING btree (upcoming_page_subscriber_id);


--
-- Name: index_upcoming_page_messages_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_messages_on_post_id ON public.upcoming_page_messages USING btree (post_id);


--
-- Name: index_upcoming_page_messages_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_messages_on_slug ON public.upcoming_page_messages USING btree (slug);


--
-- Name: index_upcoming_page_messages_on_upcoming_page_survey_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_messages_on_upcoming_page_survey_id ON public.upcoming_page_messages USING btree (upcoming_page_survey_id);


--
-- Name: index_upcoming_page_messages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_messages_on_user_id ON public.upcoming_page_messages USING btree (user_id);


--
-- Name: index_upcoming_page_question_rules_on_upcoming_page_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_question_rules_on_upcoming_page_question_id ON public.upcoming_page_question_rules USING btree (upcoming_page_question_id);


--
-- Name: index_upcoming_page_questions_on_upcoming_page_survey_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_questions_on_upcoming_page_survey_id ON public.upcoming_page_questions USING btree (upcoming_page_survey_id);


--
-- Name: index_upcoming_page_segments_on_upcoming_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_segments_on_upcoming_page_id ON public.upcoming_page_segments USING btree (upcoming_page_id);


--
-- Name: index_upcoming_page_subscriber_searches_on_upcoming_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_subscriber_searches_on_upcoming_page_id ON public.upcoming_page_subscriber_searches USING btree (upcoming_page_id);


--
-- Name: index_upcoming_page_subscribers_on_page_id_and_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_upcoming_page_subscribers_on_page_id_and_contact_id ON public.upcoming_page_subscribers USING btree (upcoming_page_id, ship_contact_id);


--
-- Name: index_upcoming_page_subscribers_on_ship_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_subscribers_on_ship_contact_id ON public.upcoming_page_subscribers USING btree (ship_contact_id);


--
-- Name: index_upcoming_page_subscribers_on_source_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_subscribers_on_source_kind ON public.upcoming_page_subscribers USING btree (source_kind);


--
-- Name: index_upcoming_page_subscribers_on_upcoming_page_id_and_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_subscribers_on_upcoming_page_id_and_state ON public.upcoming_page_subscribers USING btree (upcoming_page_id, state);


--
-- Name: index_upcoming_page_surveys_on_upcoming_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_page_surveys_on_upcoming_page_id ON public.upcoming_page_surveys USING btree (upcoming_page_id);


--
-- Name: index_upcoming_page_variants_on_upcoming_page_id_and_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_upcoming_page_variants_on_upcoming_page_id_and_kind ON public.upcoming_page_variants USING btree (upcoming_page_id, kind);


--
-- Name: index_upcoming_pages_on_inbox_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_upcoming_pages_on_inbox_slug ON public.upcoming_pages USING btree (inbox_slug);


--
-- Name: index_upcoming_pages_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_pages_on_name ON public.upcoming_pages USING gin (name public.gin_trgm_ops);


--
-- Name: index_upcoming_pages_on_ship_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_pages_on_ship_account_id ON public.upcoming_pages USING btree (ship_account_id);


--
-- Name: index_upcoming_pages_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_upcoming_pages_on_slug ON public.upcoming_pages USING btree (slug);


--
-- Name: index_upcoming_pages_on_trashed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_pages_on_trashed_at ON public.upcoming_pages USING btree (trashed_at);


--
-- Name: index_upcoming_pages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_pages_on_user_id ON public.upcoming_pages USING btree (user_id);


--
-- Name: index_upcoming_question_answers_on_upcoming_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_upcoming_question_answers_on_upcoming_question_id ON public.upcoming_page_question_answers USING btree (upcoming_page_question_id);


--
-- Name: index_user_activities_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_activities_unique ON public.user_activity_events USING btree (user_id, subject_type, subject_id);


--
-- Name: index_user_activity_events_on_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_activity_events_on_subject ON public.user_activity_events USING btree (subject_type, subject_id);


--
-- Name: index_user_delete_surveys_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_delete_surveys_on_user_id ON public.user_delete_surveys USING btree (user_id);


--
-- Name: index_user_follow_product_requests_on_product_request; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_follow_product_requests_on_product_request ON public.user_follow_product_request_associations USING btree (product_request_id);


--
-- Name: index_user_follow_product_requests_on_user_and_product_request; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_follow_product_requests_on_user_and_product_request ON public.user_follow_product_request_associations USING btree (user_id, product_request_id);


--
-- Name: index_user_friend_associations_on_created_and_followed_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_friend_associations_on_created_and_followed_by ON public.user_friend_associations USING btree (created_at, followed_by_user_id);


--
-- Name: index_user_friend_associations_on_following_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_friend_associations_on_following_user_id ON public.user_friend_associations USING btree (following_user_id);


--
-- Name: index_user_friend_associations_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_friend_associations_on_source ON public.user_friend_associations USING btree (source) WHERE (source IS NOT NULL);


--
-- Name: index_user_friend_assocs_followed_following; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_friend_assocs_followed_following ON public.user_friend_associations USING btree (followed_by_user_id, following_user_id);


--
-- Name: index_user_visit_streak_reminders_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_visit_streak_reminders_on_user_id ON public.user_visit_streak_reminders USING btree (user_id);


--
-- Name: index_users_browser_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_browser_logs_on_user_id ON public.users_browser_logs USING btree (user_id);


--
-- Name: index_users_crypto_wallets_on_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_crypto_wallets_on_address ON public.users_crypto_wallets USING btree (address);


--
-- Name: index_users_crypto_wallets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_crypto_wallets_on_user_id ON public.users_crypto_wallets USING btree (user_id);


--
-- Name: index_users_deleted_karma_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_deleted_karma_logs_on_user_id ON public.users_deleted_karma_logs USING btree (user_id);


--
-- Name: index_users_links_on_user_id_and_url; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_links_on_user_id_and_url ON public.users_links USING btree (user_id, url);


--
-- Name: index_users_new_social_logins_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_new_social_logins_on_state ON public.users_new_social_logins USING btree (state);


--
-- Name: index_users_new_social_logins_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_new_social_logins_on_token ON public.users_new_social_logins USING btree (token);


--
-- Name: index_users_new_social_logins_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_new_social_logins_on_user_id ON public.users_new_social_logins USING btree (user_id);


--
-- Name: index_users_on_ambassador; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_ambassador ON public.users USING btree (ambassador);


--
-- Name: index_users_on_angellist_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_angellist_uid ON public.users USING btree (angellist_uid);


--
-- Name: index_users_on_apple_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_apple_uid ON public.users USING btree (apple_uid);


--
-- Name: index_users_on_default_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_default_collection_id ON public.users USING btree (default_collection_id);


--
-- Name: index_users_on_follower_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_follower_count ON public.users USING btree (follower_count);


--
-- Name: index_users_on_google_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_google_uid ON public.users USING btree (google_uid);


--
-- Name: index_users_on_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_role ON public.users USING btree (role);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: index_users_registration_reasons_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_registration_reasons_on_user_id ON public.users_registration_reasons USING btree (user_id);


--
-- Name: index_visit_streaks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visit_streaks_on_user_id ON public.visit_streaks USING btree (user_id);


--
-- Name: index_vote_check_results_on_vote_id_and_check; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vote_check_results_on_vote_id_and_check ON public.vote_check_results USING btree (vote_id, "check");


--
-- Name: index_vote_infos_on_vote_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vote_infos_on_vote_id ON public.vote_infos USING btree (vote_id);


--
-- Name: index_votes_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_created_at ON public.votes USING btree (created_at);


--
-- Name: index_votes_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_source ON public.votes USING btree (source) WHERE (source IS NOT NULL);


--
-- Name: index_votes_on_subject_type_and_subject_id_and_credible; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_subject_type_and_subject_id_and_credible ON public.votes USING btree (subject_type, subject_id, credible);


--
-- Name: index_votes_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_updated_at ON public.votes USING btree (updated_at);


--
-- Name: index_votes_on_user_id_and_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_votes_on_user_id_and_subject_type_and_subject_id ON public.votes USING btree (user_id, subject_type, subject_id);


--
-- Name: notification_logs_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX notification_logs_unique ON public.notification_logs USING btree (subscriber_id, kind, notifyable_id, notifyable_type);


--
-- Name: notification_unsubscription_logs_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX notification_unsubscription_logs_unique ON public.notification_unsubscription_logs USING btree (notifyable_type, notifyable_id, kind, channel_name, subscriber_id) WHERE ((notifyable_id IS NOT NULL) AND (notifyable_type IS NOT NULL));


--
-- Name: posts_user_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_user_id_idx ON public.posts USING btree (user_id) WHERE (trashed_at IS NULL);


--
-- Name: product_request_topic_associations_product_request_topic; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX product_request_topic_associations_product_request_topic ON public.product_request_topic_associations USING btree (product_request_id, topic_id);


--
-- Name: ship_account_member_associations_user_id_and_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ship_account_member_associations_user_id_and_account_id ON public.ship_account_member_associations USING btree (ship_account_id, user_id);


--
-- Name: twitter_verified_users_lower_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX twitter_verified_users_lower_idx ON public.twitter_verified_users USING btree (lower(twitter_username));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: upcoming_page_subscriber_assoc_segment_subscriber; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX upcoming_page_subscriber_assoc_segment_subscriber ON public.upcoming_page_segment_subscriber_associations USING btree (upcoming_page_segment_id, upcoming_page_subscriber_id);


--
-- Name: upcoming_page_topic_associations_upcoming_page_topic; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX upcoming_page_topic_associations_upcoming_page_topic ON public.upcoming_page_topic_associations USING btree (upcoming_page_id, topic_id);


--
-- Name: user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_index ON public.audits USING btree (user_id, user_type);


--
-- Name: users_facebook_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_facebook_uid_idx ON public.users USING btree (facebook_uid) WHERE (trashed_at IS NULL);


--
-- Name: users_on_name_fast; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_on_name_fast ON public.users USING gin (name public.gin_trgm_ops);


--
-- Name: users_on_username_fast; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_on_username_fast ON public.users USING gin (username public.gin_trgm_ops);


--
-- Name: users_twitter_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_twitter_uid_idx ON public.users USING btree (twitter_uid) WHERE (trashed_at IS NULL);


--
-- Name: collection_post_associations collection_post_associations_minhash_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER collection_post_associations_minhash_change_trigger AFTER INSERT OR DELETE ON public.collection_post_associations FOR EACH ROW EXECUTE FUNCTION public.recompute_post_ids_minhash_signature_for_collection_trigger();

ALTER TABLE public.collection_post_associations DISABLE TRIGGER collection_post_associations_minhash_change_trigger;


--
-- Name: post_topic_associations post_topic_associations_minhash_change_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER post_topic_associations_minhash_change_trigger AFTER INSERT OR DELETE ON public.post_topic_associations FOR EACH ROW EXECUTE FUNCTION public.recompute_post_ids_minhash_signature_for_topic_trigger();

ALTER TABLE public.post_topic_associations DISABLE TRIGGER post_topic_associations_minhash_change_trigger;


--
-- Name: disabled_friend_syncs disabled_twitter_syncs_followed_by_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disabled_friend_syncs
    ADD CONSTRAINT disabled_twitter_syncs_followed_by_user_id_fk FOREIGN KEY (followed_by_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: disabled_friend_syncs disabled_twitter_syncs_following_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disabled_friend_syncs
    ADD CONSTRAINT disabled_twitter_syncs_following_user_id_fk FOREIGN KEY (following_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: founder_club_access_requests fk_rails_004dff2203; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_access_requests
    ADD CONSTRAINT fk_rails_004dff2203 FOREIGN KEY (payment_discount_id) REFERENCES public.payment_discounts(id);


--
-- Name: golden_kitty_categories fk_rails_01eb1e2e57; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_categories
    ADD CONSTRAINT fk_rails_01eb1e2e57 FOREIGN KEY (sponsor_id) REFERENCES public.golden_kitty_sponsors(id);


--
-- Name: products_skip_review_suggestions fk_rails_033be125a5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products_skip_review_suggestions
    ADD CONSTRAINT fk_rails_033be125a5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_conversation_messages fk_rails_03ae55c235; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_conversation_messages
    ADD CONSTRAINT fk_rails_03ae55c235 FOREIGN KEY (upcoming_page_conversation_id) REFERENCES public.upcoming_page_conversations(id);


--
-- Name: discussion_category_associations fk_rails_04137efd74; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_category_associations
    ADD CONSTRAINT fk_rails_04137efd74 FOREIGN KEY (discussion_thread_id) REFERENCES public.discussion_threads(id);


--
-- Name: jobs fk_rails_05e11c87f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT fk_rails_05e11c87f6 FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: golden_kitty_people fk_rails_06ec9d3132; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_people
    ADD CONSTRAINT fk_rails_06ec9d3132 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: flags fk_rails_0866cf8eca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT fk_rails_0866cf8eca FOREIGN KEY (moderator_id) REFERENCES public.users(id);


--
-- Name: banners fk_rails_0a18452926; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banners
    ADD CONSTRAINT fk_rails_0a18452926 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_follow_product_request_associations fk_rails_0a5316cbc6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_follow_product_request_associations
    ADD CONSTRAINT fk_rails_0a5316cbc6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: spam_filter_values fk_rails_0e382f1150; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_filter_values
    ADD CONSTRAINT fk_rails_0e382f1150 FOREIGN KEY (added_by_id) REFERENCES public.users(id);


--
-- Name: spam_reports fk_rails_121f3a2011; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_reports
    ADD CONSTRAINT fk_rails_121f3a2011 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ship_accounts fk_rails_1344034e83; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_accounts
    ADD CONSTRAINT fk_rails_1344034e83 FOREIGN KEY (ship_subscription_id) REFERENCES public.ship_subscriptions(id);


--
-- Name: newsletter_events fk_rails_140dcd78c2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_events
    ADD CONSTRAINT fk_rails_140dcd78c2 FOREIGN KEY (newsletter_id) REFERENCES public.newsletters(id);


--
-- Name: ship_account_member_associations fk_rails_14acf0ba19; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_account_member_associations
    ADD CONSTRAINT fk_rails_14acf0ba19 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: newsletter_variants fk_rails_17ffc2bc14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_variants
    ADD CONSTRAINT fk_rails_17ffc2bc14 FOREIGN KEY (newsletter_experiment_id) REFERENCES public.newsletter_experiments(id);


--
-- Name: spam_reports fk_rails_184020243a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_reports
    ADD CONSTRAINT fk_rails_184020243a FOREIGN KEY (handled_by_id) REFERENCES public.users(id);


--
-- Name: comment_awards fk_rails_18e75ca29d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_awards
    ADD CONSTRAINT fk_rails_18e75ca29d FOREIGN KEY (awarded_by_id) REFERENCES public.users(id);


--
-- Name: payment_subscriptions fk_rails_1b357e24d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_subscriptions
    ADD CONSTRAINT fk_rails_1b357e24d1 FOREIGN KEY (discount_id) REFERENCES public.payment_discounts(id);


--
-- Name: promoted_analytics fk_rails_1bfffd421b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_analytics
    ADD CONSTRAINT fk_rails_1bfffd421b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_variants fk_rails_1ca1a7a320; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_variants
    ADD CONSTRAINT fk_rails_1ca1a7a320 FOREIGN KEY (upcoming_page_id) REFERENCES public.upcoming_pages(id);


--
-- Name: spam_logs fk_rails_1cb83308b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_logs
    ADD CONSTRAINT fk_rails_1cb83308b1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_subscriber_searches fk_rails_1cf967f775; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_subscriber_searches
    ADD CONSTRAINT fk_rails_1cf967f775 FOREIGN KEY (upcoming_page_id) REFERENCES public.upcoming_pages(id);


--
-- Name: promoted_products fk_rails_1d2840c1e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_products
    ADD CONSTRAINT fk_rails_1d2840c1e9 FOREIGN KEY (newsletter_id) REFERENCES public.newsletters(id);


--
-- Name: promoted_email_signups fk_rails_1d968ad1de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_signups
    ADD CONSTRAINT fk_rails_1d968ad1de FOREIGN KEY (promoted_email_campaign_id) REFERENCES public.promoted_email_campaigns(id);


--
-- Name: spam_logs fk_rails_1f40c189e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_logs
    ADD CONSTRAINT fk_rails_1f40c189e7 FOREIGN KEY (parent_log_id) REFERENCES public.spam_logs(id);


--
-- Name: onboarding_reasons fk_rails_1f797c87a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onboarding_reasons
    ADD CONSTRAINT fk_rails_1f797c87a9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: founder_club_claims fk_rails_204048c527; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_claims
    ADD CONSTRAINT fk_rails_204048c527 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: founder_club_access_requests fk_rails_2151f24a53; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_access_requests
    ADD CONSTRAINT fk_rails_2151f24a53 FOREIGN KEY (invited_by_user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_conversation_messages fk_rails_23287bc3bf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_conversation_messages
    ADD CONSTRAINT fk_rails_23287bc3bf FOREIGN KEY (upcoming_page_email_reply_id) REFERENCES public.upcoming_page_email_replies(id);


--
-- Name: promoted_products fk_rails_23ff458f37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_products
    ADD CONSTRAINT fk_rails_23ff458f37 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: upcoming_page_question_answers fk_rails_2441d2a886; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_question_answers
    ADD CONSTRAINT fk_rails_2441d2a886 FOREIGN KEY (upcoming_page_subscriber_id) REFERENCES public.upcoming_page_subscribers(id);


--
-- Name: ab_test_participants fk_rails_251df02381; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ab_test_participants
    ADD CONSTRAINT fk_rails_251df02381 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: newsletter_experiments fk_rails_264ea3c753; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_experiments
    ADD CONSTRAINT fk_rails_264ea3c753 FOREIGN KEY (newsletter_id) REFERENCES public.newsletters(id);


--
-- Name: newsletter_events fk_rails_2777e1eaf6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_events
    ADD CONSTRAINT fk_rails_2777e1eaf6 FOREIGN KEY (subscriber_id) REFERENCES public.notifications_subscribers(id);


--
-- Name: team_requests fk_rails_27bc33b83b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_requests
    ADD CONSTRAINT fk_rails_27bc33b83b FOREIGN KEY (status_changed_by_id) REFERENCES public.users(id);


--
-- Name: comment_prompts fk_rails_27c4116404; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_prompts
    ADD CONSTRAINT fk_rails_27c4116404 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: spam_rule_logs fk_rails_2a1dfce904; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rule_logs
    ADD CONSTRAINT fk_rails_2a1dfce904 FOREIGN KEY (spam_rule_id) REFERENCES public.spam_rules(id);


--
-- Name: moderation_locks fk_rails_2a8497f539; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_locks
    ADD CONSTRAINT fk_rails_2a8497f539 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ship_account_member_associations fk_rails_2c1c1ee24d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_account_member_associations
    ADD CONSTRAINT fk_rails_2c1c1ee24d FOREIGN KEY (ship_account_id) REFERENCES public.ship_accounts(id);


--
-- Name: upcoming_page_message_deliveries fk_rails_2d8a4fff62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_message_deliveries
    ADD CONSTRAINT fk_rails_2d8a4fff62 FOREIGN KEY (upcoming_page_subscriber_id) REFERENCES public.upcoming_page_subscribers(id);


--
-- Name: founder_club_claims fk_rails_2f1dd46f04; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_claims
    ADD CONSTRAINT fk_rails_2f1dd46f04 FOREIGN KEY (redemption_code_id) REFERENCES public.founder_club_redemption_codes(id);


--
-- Name: spam_multiple_accounts_logs fk_rails_2f5d8528dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_multiple_accounts_logs
    ADD CONSTRAINT fk_rails_2f5d8528dc FOREIGN KEY (previous_user_id) REFERENCES public.users(id);


--
-- Name: product_scrape_results fk_rails_310bda3a35; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_scrape_results
    ADD CONSTRAINT fk_rails_310bda3a35 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: makers_festival_categories fk_rails_328ac39015; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_categories
    ADD CONSTRAINT fk_rails_328ac39015 FOREIGN KEY (makers_festival_edition_id) REFERENCES public.makers_festival_editions(id);


--
-- Name: golden_kitty_categories fk_rails_32b6e145e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_categories
    ADD CONSTRAINT fk_rails_32b6e145e6 FOREIGN KEY (edition_id) REFERENCES public.golden_kitty_editions(id);


--
-- Name: golden_kitty_facts fk_rails_33ffcc3766; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_facts
    ADD CONSTRAINT fk_rails_33ffcc3766 FOREIGN KEY (category_id) REFERENCES public.golden_kitty_categories(id);


--
-- Name: payment_subscriptions fk_rails_34ac7b49ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_subscriptions
    ADD CONSTRAINT fk_rails_34ac7b49ca FOREIGN KEY (plan_id) REFERENCES public.payment_plans(id);


--
-- Name: makers_festival_participants fk_rails_35603b7346; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_participants
    ADD CONSTRAINT fk_rails_35603b7346 FOREIGN KEY (makers_festival_category_id) REFERENCES public.makers_festival_categories(id);


--
-- Name: input_suggestions fk_rails_35804c4ac9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.input_suggestions
    ADD CONSTRAINT fk_rails_35804c4ac9 FOREIGN KEY (parent_id) REFERENCES public.input_suggestions(id);


--
-- Name: moderation_skips fk_rails_35ce49d00c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_skips
    ADD CONSTRAINT fk_rails_35ce49d00c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: spam_manual_logs fk_rails_36603c0f5d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_manual_logs
    ADD CONSTRAINT fk_rails_36603c0f5d FOREIGN KEY (reverted_by_id) REFERENCES public.users(id);


--
-- Name: founder_club_deals fk_rails_368bd745ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_deals
    ADD CONSTRAINT fk_rails_368bd745ac FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: posts fk_rails_36f4d9b683; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_rails_36f4d9b683 FOREIGN KEY (product_id) REFERENCES public.legacy_products(id);


--
-- Name: users fk_rails_372edb1c62; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_372edb1c62 FOREIGN KEY (default_collection_id) REFERENCES public.collections(id);


--
-- Name: ship_tracking_events fk_rails_37fc0945ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_tracking_events
    ADD CONSTRAINT fk_rails_37fc0945ac FOREIGN KEY (ship_tracking_identity_id) REFERENCES public.ship_tracking_identities(id);


--
-- Name: ads_budgets fk_rails_3a64afb235; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_budgets
    ADD CONSTRAINT fk_rails_3a64afb235 FOREIGN KEY (campaign_id) REFERENCES public.ads_campaigns(id);


--
-- Name: founder_club_redemption_codes fk_rails_3af6559680; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_redemption_codes
    ADD CONSTRAINT fk_rails_3af6559680 FOREIGN KEY (deal_id) REFERENCES public.founder_club_deals(id);


--
-- Name: newsletter_events fk_rails_3b35d5f60b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_events
    ADD CONSTRAINT fk_rails_3b35d5f60b FOREIGN KEY (newsletter_variant_id) REFERENCES public.newsletter_variants(id);


--
-- Name: product_request_topic_associations fk_rails_3c0b690e03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_request_topic_associations
    ADD CONSTRAINT fk_rails_3c0b690e03 FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: product_activity_events fk_rails_3c66761f26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_activity_events
    ADD CONSTRAINT fk_rails_3c66761f26 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: ship_subscriptions fk_rails_3d49cebf89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_subscriptions
    ADD CONSTRAINT fk_rails_3d49cebf89 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: clearbit_people_companies fk_rails_3fe4351a7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clearbit_people_companies
    ADD CONSTRAINT fk_rails_3fe4351a7e FOREIGN KEY (company_id) REFERENCES public.clearbit_company_profiles(id);


--
-- Name: post_topic_associations fk_rails_41eeb01111; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_topic_associations
    ADD CONSTRAINT fk_rails_41eeb01111 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_topic_associations fk_rails_4273742159; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_topic_associations
    ADD CONSTRAINT fk_rails_4273742159 FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: spam_reports fk_rails_43a6cdfaba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_reports
    ADD CONSTRAINT fk_rails_43a6cdfaba FOREIGN KEY (spam_action_log_id) REFERENCES public.spam_action_logs(id);


--
-- Name: product_screenshots fk_rails_47383d0c23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_screenshots
    ADD CONSTRAINT fk_rails_47383d0c23 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_question_answers fk_rails_4aa0c8a81c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_question_answers
    ADD CONSTRAINT fk_rails_4aa0c8a81c FOREIGN KEY (upcoming_page_question_id) REFERENCES public.upcoming_page_questions(id);


--
-- Name: ads_newsletters fk_rails_4dbf41344f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_newsletters
    ADD CONSTRAINT fk_rails_4dbf41344f FOREIGN KEY (budget_id) REFERENCES public.ads_budgets(id);


--
-- Name: golden_kitty_edition_sponsors fk_rails_50cf6ffbfe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_edition_sponsors
    ADD CONSTRAINT fk_rails_50cf6ffbfe FOREIGN KEY (sponsor_id) REFERENCES public.golden_kitty_sponsors(id);


--
-- Name: post_topic_associations fk_rails_52d1238d56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_topic_associations
    ADD CONSTRAINT fk_rails_52d1238d56 FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: clearbit_people_companies fk_rails_572f98ba7d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clearbit_people_companies
    ADD CONSTRAINT fk_rails_572f98ba7d FOREIGN KEY (person_id) REFERENCES public.clearbit_person_profiles(id);


--
-- Name: file_exports fk_rails_576b1d535d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_exports
    ADD CONSTRAINT fk_rails_576b1d535d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: anthologies_story_mentions_associations fk_rails_584de1c3b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthologies_story_mentions_associations
    ADD CONSTRAINT fk_rails_584de1c3b7 FOREIGN KEY (story_id) REFERENCES public.anthologies_stories(id);


--
-- Name: products_skip_review_suggestions fk_rails_59841aa399; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products_skip_review_suggestions
    ADD CONSTRAINT fk_rails_59841aa399 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: collection_topic_associations fk_rails_5cb7c9a878; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_topic_associations
    ADD CONSTRAINT fk_rails_5cb7c9a878 FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: upcoming_page_surveys fk_rails_5e3c1e4882; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_surveys
    ADD CONSTRAINT fk_rails_5e3c1e4882 FOREIGN KEY (upcoming_page_id) REFERENCES public.upcoming_pages(id);


--
-- Name: topics fk_rails_5f3c091f12; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT fk_rails_5f3c091f12 FOREIGN KEY (parent_id) REFERENCES public.topics(id);


--
-- Name: spam_rulesets fk_rails_605b18ffab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rulesets
    ADD CONSTRAINT fk_rails_605b18ffab FOREIGN KEY (added_by_id) REFERENCES public.users(id);


--
-- Name: ship_contacts fk_rails_635311b765; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_contacts
    ADD CONSTRAINT fk_rails_635311b765 FOREIGN KEY (ship_account_id) REFERENCES public.ship_accounts(id);


--
-- Name: comment_awards fk_rails_63d0d9392a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_awards
    ADD CONSTRAINT fk_rails_63d0d9392a FOREIGN KEY (awarded_to_id) REFERENCES public.users(id);


--
-- Name: moderation_duplicate_post_requests fk_rails_63fc34e7aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_duplicate_post_requests
    ADD CONSTRAINT fk_rails_63fc34e7aa FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: change_log_entries fk_rails_63fe9acf94; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_entries
    ADD CONSTRAINT fk_rails_63fe9acf94 FOREIGN KEY (discussion_thread_id) REFERENCES public.discussion_threads(id);


--
-- Name: oauth_requests fk_rails_6471c0c593; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_requests
    ADD CONSTRAINT fk_rails_6471c0c593 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: cookie_policy_logs fk_rails_65561ed956; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cookie_policy_logs
    ADD CONSTRAINT fk_rails_65561ed956 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: makers_festival_makers fk_rails_6562480848; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_makers
    ADD CONSTRAINT fk_rails_6562480848 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ship_billing_informations fk_rails_665f390188; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_billing_informations
    ADD CONSTRAINT fk_rails_665f390188 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_segments fk_rails_681c22f934; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_segments
    ADD CONSTRAINT fk_rails_681c22f934 FOREIGN KEY (upcoming_page_id) REFERENCES public.upcoming_pages(id);


--
-- Name: multi_factor_tokens fk_rails_696a12498f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.multi_factor_tokens
    ADD CONSTRAINT fk_rails_696a12498f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: stream_feed_items fk_rails_697a931858; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stream_feed_items
    ADD CONSTRAINT fk_rails_697a931858 FOREIGN KEY (receiver_id) REFERENCES public.users(id);


--
-- Name: ads_campaigns fk_rails_69e5eeb318; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_campaigns
    ADD CONSTRAINT fk_rails_69e5eeb318 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: golden_kitty_people fk_rails_6c1c334fd7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_people
    ADD CONSTRAINT fk_rails_6c1c334fd7 FOREIGN KEY (golden_kitty_category_id) REFERENCES public.golden_kitty_categories(id);


--
-- Name: users_deleted_karma_logs fk_rails_6c80600f2a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_deleted_karma_logs
    ADD CONSTRAINT fk_rails_6c80600f2a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_email_imports fk_rails_6f396e2716; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_email_imports
    ADD CONSTRAINT fk_rails_6f396e2716 FOREIGN KEY (upcoming_page_segment_id) REFERENCES public.upcoming_page_segments(id);


--
-- Name: golden_kitty_finalists fk_rails_6f8364295f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_finalists
    ADD CONSTRAINT fk_rails_6f8364295f FOREIGN KEY (golden_kitty_category_id) REFERENCES public.golden_kitty_categories(id);


--
-- Name: founder_club_access_requests fk_rails_7020d236fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_access_requests
    ADD CONSTRAINT fk_rails_7020d236fd FOREIGN KEY (deal_id) REFERENCES public.founder_club_deals(id);


--
-- Name: team_requests fk_rails_71d341f394; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_requests
    ADD CONSTRAINT fk_rails_71d341f394 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payment_plan_discount_associations fk_rails_726ce81488; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_plan_discount_associations
    ADD CONSTRAINT fk_rails_726ce81488 FOREIGN KEY (discount_id) REFERENCES public.payment_discounts(id);


--
-- Name: founder_club_claims fk_rails_731595f831; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_claims
    ADD CONSTRAINT fk_rails_731595f831 FOREIGN KEY (deal_id) REFERENCES public.founder_club_deals(id);


--
-- Name: makers_festival_participants fk_rails_73bcbcada9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_participants
    ADD CONSTRAINT fk_rails_73bcbcada9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: goals fk_rails_74e250c303; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT fk_rails_74e250c303 FOREIGN KEY (maker_group_id) REFERENCES public.maker_groups(id);


--
-- Name: team_requests fk_rails_77e98aeee1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_requests
    ADD CONSTRAINT fk_rails_77e98aeee1 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: onboardings fk_rails_79b836a814; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onboardings
    ADD CONSTRAINT fk_rails_79b836a814 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: legacy_product_links fk_rails_7a63a705f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_product_links
    ADD CONSTRAINT fk_rails_7a63a705f1 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: team_members fk_rails_7b719b827d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT fk_rails_7b719b827d FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: review_tag_associations fk_rails_7c09a15de0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_tag_associations
    ADD CONSTRAINT fk_rails_7c09a15de0 FOREIGN KEY (review_id) REFERENCES public.reviews(id);


--
-- Name: promoted_analytics fk_rails_7c3572034d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_analytics
    ADD CONSTRAINT fk_rails_7c3572034d FOREIGN KEY (promoted_product_id) REFERENCES public.promoted_products(id);


--
-- Name: notifications_subscribers fk_rails_808ab58506; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications_subscribers
    ADD CONSTRAINT fk_rails_808ab58506 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_conversation_messages fk_rails_80dbe3156c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_conversation_messages
    ADD CONSTRAINT fk_rails_80dbe3156c FOREIGN KEY (upcoming_page_subscriber_id) REFERENCES public.upcoming_page_subscribers(id);


--
-- Name: user_follow_product_request_associations fk_rails_811ca6e5f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_follow_product_request_associations
    ADD CONSTRAINT fk_rails_811ca6e5f1 FOREIGN KEY (product_request_id) REFERENCES public.product_requests(id);


--
-- Name: maker_fest_participants fk_rails_8177214acd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_fest_participants
    ADD CONSTRAINT fk_rails_8177214acd FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: shoutouts fk_rails_818bc1b02c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shoutouts
    ADD CONSTRAINT fk_rails_818bc1b02c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_pages fk_rails_8693da9733; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_pages
    ADD CONSTRAINT fk_rails_8693da9733 FOREIGN KEY (ship_account_id) REFERENCES public.ship_accounts(id);


--
-- Name: ship_contacts fk_rails_86b3d655c8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_contacts
    ADD CONSTRAINT fk_rails_86b3d655c8 FOREIGN KEY (clearbit_person_profile_id) REFERENCES public.clearbit_person_profiles(id);


--
-- Name: upcoming_page_messages fk_rails_86e84129ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_messages
    ADD CONSTRAINT fk_rails_86e84129ee FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: discussion_category_associations fk_rails_87aea006d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_category_associations
    ADD CONSTRAINT fk_rails_87aea006d6 FOREIGN KEY (category_id) REFERENCES public.discussion_categories(id);


--
-- Name: house_keeper_broken_links fk_rails_8831b35283; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.house_keeper_broken_links
    ADD CONSTRAINT fk_rails_8831b35283 FOREIGN KEY (product_link_id) REFERENCES public.legacy_product_links(id);


--
-- Name: questions fk_rails_8a842bcd2f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT fk_rails_8a842bcd2f FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: ship_contacts fk_rails_8b418fb1f7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_contacts
    ADD CONSTRAINT fk_rails_8b418fb1f7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_segment_subscriber_associations fk_rails_8bd880c6a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_segment_subscriber_associations
    ADD CONSTRAINT fk_rails_8bd880c6a1 FOREIGN KEY (upcoming_page_subscriber_id) REFERENCES public.upcoming_page_subscribers(id);


--
-- Name: posts_launch_day_reports fk_rails_8c1e0638f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts_launch_day_reports
    ADD CONSTRAINT fk_rails_8c1e0638f8 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: spam_multiple_accounts_logs fk_rails_8ca0e7901d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_multiple_accounts_logs
    ADD CONSTRAINT fk_rails_8ca0e7901d FOREIGN KEY (current_user_id) REFERENCES public.users(id);


--
-- Name: maker_group_members fk_rails_8cdb57a625; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_group_members
    ADD CONSTRAINT fk_rails_8cdb57a625 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payment_card_update_logs fk_rails_905a5774bc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_card_update_logs
    ADD CONSTRAINT fk_rails_905a5774bc FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: comment_awards fk_rails_90eb39544e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_awards
    ADD CONSTRAINT fk_rails_90eb39544e FOREIGN KEY (comment_id) REFERENCES public.comments(id);


--
-- Name: founder_club_access_requests fk_rails_92b48651c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founder_club_access_requests
    ADD CONSTRAINT fk_rails_92b48651c1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: spam_manual_logs fk_rails_9430800d93; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_manual_logs
    ADD CONSTRAINT fk_rails_9430800d93 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: reviews fk_rails_9536b896d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_rails_9536b896d8 FOREIGN KEY (comment_id) REFERENCES public.comments(id);


--
-- Name: spam_manual_logs fk_rails_967d1fa752; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_manual_logs
    ADD CONSTRAINT fk_rails_967d1fa752 FOREIGN KEY (handled_by_id) REFERENCES public.users(id);


--
-- Name: newsletter_sponsors fk_rails_971f0e2c65; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newsletter_sponsors
    ADD CONSTRAINT fk_rails_971f0e2c65 FOREIGN KEY (newsletter_id) REFERENCES public.newsletters(id);


--
-- Name: team_invites fk_rails_97ac301329; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invites
    ADD CONSTRAINT fk_rails_97ac301329 FOREIGN KEY (referrer_id) REFERENCES public.users(id);


--
-- Name: product_request_topic_associations fk_rails_9a80c62ad6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_request_topic_associations
    ADD CONSTRAINT fk_rails_9a80c62ad6 FOREIGN KEY (product_request_id) REFERENCES public.product_requests(id);


--
-- Name: golden_kitty_categories fk_rails_9b8b952b65; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_categories
    ADD CONSTRAINT fk_rails_9b8b952b65 FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: golden_kitty_edition_sponsors fk_rails_9bb8219bfc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_edition_sponsors
    ADD CONSTRAINT fk_rails_9bb8219bfc FOREIGN KEY (edition_id) REFERENCES public.golden_kitty_editions(id);


--
-- Name: notification_logs fk_rails_9be4be49eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_logs
    ADD CONSTRAINT fk_rails_9be4be49eb FOREIGN KEY (subscriber_id) REFERENCES public.notifications_subscribers(id);


--
-- Name: post_drafts fk_rails_9c96690e91; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_drafts
    ADD CONSTRAINT fk_rails_9c96690e91 FOREIGN KEY (suggested_product_id) REFERENCES public.products(id);


--
-- Name: upcoming_page_segment_subscriber_associations fk_rails_9d87aa5543; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_segment_subscriber_associations
    ADD CONSTRAINT fk_rails_9d87aa5543 FOREIGN KEY (upcoming_page_segment_id) REFERENCES public.upcoming_page_segments(id);


--
-- Name: funding_surveys fk_rails_9d8ca6e3cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funding_surveys
    ADD CONSTRAINT fk_rails_9d8ca6e3cc FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: team_members fk_rails_9ec2d5e75e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT fk_rails_9ec2d5e75e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: collection_topic_associations fk_rails_9f0320ec55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_topic_associations
    ADD CONSTRAINT fk_rails_9f0320ec55 FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: anthologies_stories fk_rails_9fc63e6744; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthologies_stories
    ADD CONSTRAINT fk_rails_9fc63e6744 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: promoted_email_signups fk_rails_a1701c07bf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_signups
    ADD CONSTRAINT fk_rails_a1701c07bf FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: spam_action_logs fk_rails_a1fd348647; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_action_logs
    ADD CONSTRAINT fk_rails_a1fd348647 FOREIGN KEY (spam_ruleset_id) REFERENCES public.spam_rulesets(id);


--
-- Name: collection_product_associations fk_rails_a4c2b3201c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_product_associations
    ADD CONSTRAINT fk_rails_a4c2b3201c FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: reviews fk_rails_a4cffdde38; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_rails_a4cffdde38 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: product_screenshots fk_rails_a831ca625e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_screenshots
    ADD CONSTRAINT fk_rails_a831ca625e FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: spam_action_logs fk_rails_a83a8be6db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_action_logs
    ADD CONSTRAINT fk_rails_a83a8be6db FOREIGN KEY (reverted_by_id) REFERENCES public.users(id);


--
-- Name: ads_channels fk_rails_a8a8e71f48; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_channels
    ADD CONSTRAINT fk_rails_a8a8e71f48 FOREIGN KEY (budget_id) REFERENCES public.ads_budgets(id);


--
-- Name: jobs fk_rails_a8cbc81a5e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT fk_rails_a8cbc81a5e FOREIGN KEY (jobs_discount_page_id) REFERENCES public.jobs_discount_pages(id);


--
-- Name: upcoming_page_conversations fk_rails_a98e478bd6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_conversations
    ADD CONSTRAINT fk_rails_a98e478bd6 FOREIGN KEY (upcoming_page_message_id) REFERENCES public.upcoming_page_messages(id);


--
-- Name: poll_options fk_rails_aa85becb42; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_options
    ADD CONSTRAINT fk_rails_aa85becb42 FOREIGN KEY (poll_id) REFERENCES public.polls(id);


--
-- Name: upcoming_page_conversation_messages fk_rails_aae1575a5b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_conversation_messages
    ADD CONSTRAINT fk_rails_aae1575a5b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ship_user_metadata fk_rails_abdf314b1f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_user_metadata
    ADD CONSTRAINT fk_rails_abdf314b1f FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: product_post_associations fk_rails_aca7269955; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_post_associations
    ADD CONSTRAINT fk_rails_aca7269955 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: product_post_associations fk_rails_af16d8162b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_post_associations
    ADD CONSTRAINT fk_rails_af16d8162b FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: spam_rule_logs fk_rails_af2acd4b99; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rule_logs
    ADD CONSTRAINT fk_rails_af2acd4b99 FOREIGN KEY (spam_filter_value_id) REFERENCES public.spam_filter_values(id);


--
-- Name: moderation_duplicate_post_requests fk_rails_af30ece8da; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.moderation_duplicate_post_requests
    ADD CONSTRAINT fk_rails_af30ece8da FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: spam_rule_logs fk_rails_b153af61c4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rule_logs
    ADD CONSTRAINT fk_rails_b153af61c4 FOREIGN KEY (spam_ruleset_id) REFERENCES public.spam_rulesets(id);


--
-- Name: product_request_related_product_request_associations fk_rails_b176426753; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_request_related_product_request_associations
    ADD CONSTRAINT fk_rails_b176426753 FOREIGN KEY (related_product_request_id) REFERENCES public.product_requests(id);


--
-- Name: visit_streaks fk_rails_b7d40f7d7c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visit_streaks
    ADD CONSTRAINT fk_rails_b7d40f7d7c FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_delete_surveys fk_rails_bbb117ea21; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_delete_surveys
    ADD CONSTRAINT fk_rails_bbb117ea21 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ship_user_metadata fk_rails_bd2ef6d8ea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_user_metadata
    ADD CONSTRAINT fk_rails_bd2ef6d8ea FOREIGN KEY (ship_instant_access_page_id) REFERENCES public.ship_instant_access_pages(id);


--
-- Name: marketing_notifications fk_rails_bda9b31161; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_notifications
    ADD CONSTRAINT fk_rails_bda9b31161 FOREIGN KEY (sender_id) REFERENCES public.users(id);


--
-- Name: product_review_summaries fk_rails_bf42686f09; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_review_summaries
    ADD CONSTRAINT fk_rails_bf42686f09 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: users_links fk_rails_bf59918113; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_links
    ADD CONSTRAINT fk_rails_bf59918113 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: review_tag_associations fk_rails_c003464e37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_tag_associations
    ADD CONSTRAINT fk_rails_c003464e37 FOREIGN KEY (review_tag_id) REFERENCES public.review_tags(id);


--
-- Name: collection_product_associations fk_rails_c08da860c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_product_associations
    ADD CONSTRAINT fk_rails_c08da860c1 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: upcoming_page_questions fk_rails_c19f717c56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_questions
    ADD CONSTRAINT fk_rails_c19f717c56 FOREIGN KEY (upcoming_page_survey_id) REFERENCES public.upcoming_page_surveys(id);


--
-- Name: upcoming_page_question_options fk_rails_c1d99e77f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_question_options
    ADD CONSTRAINT fk_rails_c1d99e77f5 FOREIGN KEY (upcoming_page_question_id) REFERENCES public.upcoming_page_questions(id);


--
-- Name: team_invites fk_rails_c2538cb44a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invites
    ADD CONSTRAINT fk_rails_c2538cb44a FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: ship_tracking_identities fk_rails_c35f4c4fd1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_tracking_identities
    ADD CONSTRAINT fk_rails_c35f4c4fd1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: spam_action_logs fk_rails_c4c6476eba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_action_logs
    ADD CONSTRAINT fk_rails_c4c6476eba FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: goals fk_rails_c5fd9c8a38; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT fk_rails_c5fd9c8a38 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ads_interactions fk_rails_c79aee71a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_interactions
    ADD CONSTRAINT fk_rails_c79aee71a3 FOREIGN KEY (channel_id) REFERENCES public.ads_channels(id);


--
-- Name: upcoming_page_topic_associations fk_rails_ca5595c907; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_topic_associations
    ADD CONSTRAINT fk_rails_ca5595c907 FOREIGN KEY (upcoming_page_id) REFERENCES public.upcoming_pages(id);


--
-- Name: anthologies_related_story_associations fk_rails_cc9e06dcd8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthologies_related_story_associations
    ADD CONSTRAINT fk_rails_cc9e06dcd8 FOREIGN KEY (story_id) REFERENCES public.anthologies_stories(id);


--
-- Name: spam_rules fk_rails_cde503e860; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rules
    ADD CONSTRAINT fk_rails_cde503e860 FOREIGN KEY (spam_ruleset_id) REFERENCES public.spam_rulesets(id);


--
-- Name: product_review_summary_associations fk_rails_ce0c6c03e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_review_summary_associations
    ADD CONSTRAINT fk_rails_ce0c6c03e1 FOREIGN KEY (review_id) REFERENCES public.reviews(id);


--
-- Name: spam_rule_logs fk_rails_cf8e4a9066; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spam_rule_logs
    ADD CONSTRAINT fk_rails_cf8e4a9066 FOREIGN KEY (spam_action_log_id) REFERENCES public.spam_action_logs(id);


--
-- Name: golden_kitty_nominees fk_rails_d1cdda8c4a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_nominees
    ADD CONSTRAINT fk_rails_d1cdda8c4a FOREIGN KEY (golden_kitty_category_id) REFERENCES public.golden_kitty_categories(id);


--
-- Name: upcoming_page_conversations fk_rails_d38c5c3628; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_conversations
    ADD CONSTRAINT fk_rails_d38c5c3628 FOREIGN KEY (upcoming_page_id) REFERENCES public.upcoming_pages(id);


--
-- Name: makers_festival_editions fk_rails_d41b90abbd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_editions
    ADD CONSTRAINT fk_rails_d41b90abbd FOREIGN KEY (maker_group_id) REFERENCES public.maker_groups(id);


--
-- Name: users_registration_reasons fk_rails_d4ec02a704; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_registration_reasons
    ADD CONSTRAINT fk_rails_d4ec02a704 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: promoted_email_campaigns fk_rails_d6b660bf1b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_campaigns
    ADD CONSTRAINT fk_rails_d6b660bf1b FOREIGN KEY (promoted_email_ab_test_id) REFERENCES public.promoted_email_ab_tests(id);


--
-- Name: users_browser_logs fk_rails_d904234c47; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_browser_logs
    ADD CONSTRAINT fk_rails_d904234c47 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: poll_answers fk_rails_da1c9c019b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_answers
    ADD CONSTRAINT fk_rails_da1c9c019b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: post_topic_associations fk_rails_dad615158b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_topic_associations
    ADD CONSTRAINT fk_rails_dad615158b FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: discussion_threads fk_rails_db22b5e7b4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.discussion_threads
    ADD CONSTRAINT fk_rails_db22b5e7b4 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_question_answers fk_rails_dbf0b0c825; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_question_answers
    ADD CONSTRAINT fk_rails_dbf0b0c825 FOREIGN KEY (upcoming_page_question_option_id) REFERENCES public.upcoming_page_question_options(id);


--
-- Name: promoted_products fk_rails_dca98202ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_products
    ADD CONSTRAINT fk_rails_dca98202ef FOREIGN KEY (promoted_product_campaign_id) REFERENCES public.promoted_product_campaigns(id) ON DELETE SET NULL;


--
-- Name: poll_answers fk_rails_dddaf92868; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.poll_answers
    ADD CONSTRAINT fk_rails_dddaf92868 FOREIGN KEY (poll_option_id) REFERENCES public.poll_options(id);


--
-- Name: ship_stripe_applications fk_rails_de2b864682; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_stripe_applications
    ADD CONSTRAINT fk_rails_de2b864682 FOREIGN KEY (ship_account_id) REFERENCES public.ship_accounts(id);


--
-- Name: legacy_product_links fk_rails_de82d40cf3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legacy_product_links
    ADD CONSTRAINT fk_rails_de82d40cf3 FOREIGN KEY (product_id) REFERENCES public.legacy_products(id);


--
-- Name: jobs fk_rails_df6238c8a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT fk_rails_df6238c8a6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: makers_festival_makers fk_rails_e330eba776; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.makers_festival_makers
    ADD CONSTRAINT fk_rails_e330eba776 FOREIGN KEY (makers_festival_participant_id) REFERENCES public.makers_festival_participants(id);


--
-- Name: product_request_related_product_request_associations fk_rails_e36ad13b72; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_request_related_product_request_associations
    ADD CONSTRAINT fk_rails_e36ad13b72 FOREIGN KEY (product_request_id) REFERENCES public.product_requests(id);


--
-- Name: product_topic_associations fk_rails_e386dcec16; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_topic_associations
    ADD CONSTRAINT fk_rails_e386dcec16 FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: anthologies_related_story_associations fk_rails_e4811ebec5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anthologies_related_story_associations
    ADD CONSTRAINT fk_rails_e4811ebec5 FOREIGN KEY (related_id) REFERENCES public.anthologies_stories(id);


--
-- Name: product_review_summary_associations fk_rails_e4d579b998; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_review_summary_associations
    ADD CONSTRAINT fk_rails_e4d579b998 FOREIGN KEY (product_review_summary_id) REFERENCES public.product_review_summaries(id);


--
-- Name: notification_events fk_rails_e5260ab546; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_events
    ADD CONSTRAINT fk_rails_e5260ab546 FOREIGN KEY (notification_id) REFERENCES public.notification_logs(id);


--
-- Name: maker_fest_participants fk_rails_e5283756cf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_fest_participants
    ADD CONSTRAINT fk_rails_e5283756cf FOREIGN KEY (upcoming_page_id) REFERENCES public.upcoming_pages(id);


--
-- Name: ads_newsletter_sponsors fk_rails_e6873e7d60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ads_newsletter_sponsors
    ADD CONSTRAINT fk_rails_e6873e7d60 FOREIGN KEY (budget_id) REFERENCES public.ads_budgets(id);


--
-- Name: topic_user_associations fk_rails_e6d187817e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_user_associations
    ADD CONSTRAINT fk_rails_e6d187817e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ship_aws_applications fk_rails_e83dbad7a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_aws_applications
    ADD CONSTRAINT fk_rails_e83dbad7a8 FOREIGN KEY (ship_account_id) REFERENCES public.ship_accounts(id);


--
-- Name: ship_accounts fk_rails_e8f672af40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_accounts
    ADD CONSTRAINT fk_rails_e8f672af40 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ship_instant_access_pages fk_rails_e922d93dc8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ship_instant_access_pages
    ADD CONSTRAINT fk_rails_e922d93dc8 FOREIGN KEY (ship_invite_code_id) REFERENCES public.ship_invite_codes(id);


--
-- Name: upcoming_page_messages fk_rails_e9e4fb746f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_messages
    ADD CONSTRAINT fk_rails_e9e4fb746f FOREIGN KEY (upcoming_page_survey_id) REFERENCES public.upcoming_page_surveys(id);


--
-- Name: maker_activities fk_rails_ecd9509009; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_activities
    ADD CONSTRAINT fk_rails_ecd9509009 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: golden_kitty_finalists fk_rails_ee53537121; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.golden_kitty_finalists
    ADD CONSTRAINT fk_rails_ee53537121 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: maker_group_members fk_rails_eeb13060a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_group_members
    ADD CONSTRAINT fk_rails_eeb13060a3 FOREIGN KEY (maker_group_id) REFERENCES public.maker_groups(id);


--
-- Name: oauth_requests fk_rails_eebe401aec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_requests
    ADD CONSTRAINT fk_rails_eebe401aec FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: promoted_email_ab_test_variants fk_rails_ef74c0897d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.promoted_email_ab_test_variants
    ADD CONSTRAINT fk_rails_ef74c0897d FOREIGN KEY (promoted_email_ab_test_id) REFERENCES public.promoted_email_ab_tests(id);


--
-- Name: payment_plan_discount_associations fk_rails_f09918cd6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_plan_discount_associations
    ADD CONSTRAINT fk_rails_f09918cd6b FOREIGN KEY (plan_id) REFERENCES public.payment_plans(id);


--
-- Name: upcoming_page_message_deliveries fk_rails_f124cc0e58; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_message_deliveries
    ADD CONSTRAINT fk_rails_f124cc0e58 FOREIGN KEY (upcoming_page_message_id) REFERENCES public.upcoming_page_messages(id);


--
-- Name: product_topic_associations fk_rails_f1dba3cfad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_topic_associations
    ADD CONSTRAINT fk_rails_f1dba3cfad FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: upcoming_page_messages fk_rails_f3510ce0ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_messages
    ADD CONSTRAINT fk_rails_f3510ce0ca FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: highlighted_changes fk_rails_f354a178d3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.highlighted_changes
    ADD CONSTRAINT fk_rails_f354a178d3 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payment_subscriptions fk_rails_f47f4f3f69; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_subscriptions
    ADD CONSTRAINT fk_rails_f47f4f3f69 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users_new_social_logins fk_rails_f578a3a768; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_new_social_logins
    ADD CONSTRAINT fk_rails_f578a3a768 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: topic_aliases fk_rails_f5e5facaea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_aliases
    ADD CONSTRAINT fk_rails_f5e5facaea FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: mobile_devices fk_rails_f61b19cc7b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mobile_devices
    ADD CONSTRAINT fk_rails_f61b19cc7b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: upcoming_page_subscribers fk_rails_f6ec7d4235; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upcoming_page_subscribers
    ADD CONSTRAINT fk_rails_f6ec7d4235 FOREIGN KEY (ship_contact_id) REFERENCES public.ship_contacts(id);


--
-- Name: topic_user_associations fk_rails_f7227ac963; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.topic_user_associations
    ADD CONSTRAINT fk_rails_f7227ac963 FOREIGN KEY (topic_id) REFERENCES public.topics(id);


--
-- Name: maker_activities fk_rails_f8abdf879a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maker_activities
    ADD CONSTRAINT fk_rails_f8abdf879a FOREIGN KEY (maker_group_id) REFERENCES public.maker_groups(id);


--
-- Name: user_activity_events fk_rails_fa34fcd302; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_activity_events
    ADD CONSTRAINT fk_rails_fa34fcd302 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: onboarding_tasks fk_rails_fc1e149311; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onboarding_tasks
    ADD CONSTRAINT fk_rails_fc1e149311 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: drip_mails_scheduled_mails fk_rails_fd84a67f02; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drip_mails_scheduled_mails
    ADD CONSTRAINT fk_rails_fd84a67f02 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: team_invites fk_rails_ff219e6ecf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_invites
    ADD CONSTRAINT fk_rails_ff219e6ecf FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_friend_associations user_friend_associations_followed_by_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_friend_associations
    ADD CONSTRAINT user_friend_associations_followed_by_user_id_fk FOREIGN KEY (followed_by_user_id) REFERENCES public.users(id);


--
-- Name: user_friend_associations user_friend_associations_following_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_friend_associations
    ADD CONSTRAINT user_friend_associations_following_user_id_fk FOREIGN KEY (following_user_id) REFERENCES public.users(id);


--
-- Name: awsdms_intercept_ddl; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER awsdms_intercept_ddl ON ddl_command_end
   EXECUTE FUNCTION replication_schema.awsdms_intercept_ddl();


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20131122044337'),
('20131122050643'),
('20131122052534'),
('20131122052720'),
('20131122063823'),
('20131124190608'),
('20131125050850'),
('20131125053234'),
('20131126231826'),
('20131126234543'),
('20131127181222'),
('20131127221336'),
('20131127221536'),
('20131127225537'),
('20131128073041'),
('20131201172921'),
('20131201180801'),
('20131204005905'),
('20131209025423'),
('20131209034227'),
('20131209042018'),
('20131209051102'),
('20131222212146'),
('20140124020303'),
('20140128000705'),
('20140309203206'),
('20140309203359'),
('20140310025450'),
('20140312055938'),
('20140510160131'),
('20140513143923'),
('20140521125918'),
('20140521134602'),
('20140521134657'),
('20140521142837'),
('20140529135057'),
('20140529135136'),
('20140529135209'),
('20140529212907'),
('20140529235031'),
('20140530000700'),
('20140530180007'),
('20140603152523'),
('20140603223738'),
('20140604192734'),
('20140605131838'),
('20140612122824'),
('20140616131750'),
('20140620145857'),
('20140620150325'),
('20140623152059'),
('20140703125608'),
('20140706212951'),
('20140706215147'),
('20140706223851'),
('20140708192541'),
('20140709063026'),
('20140712230546'),
('20140715081505'),
('20140715195401'),
('20140721070738'),
('20140724035423'),
('20140724040255'),
('20140724041427'),
('20140728110309'),
('20140728200503'),
('20140729125930'),
('20140731142024'),
('20140804122827'),
('20140805073505'),
('20140806132950'),
('20140816181308'),
('20140825191715'),
('20140826193258'),
('20140906131216'),
('20140913172836'),
('20140915222418'),
('20140916184301'),
('20140916225522'),
('20140918120538'),
('20140918140117'),
('20140918142730'),
('20140918183854'),
('20140920001041'),
('20140922141620'),
('20140923130633'),
('20140929064637'),
('20141005145954'),
('20141008130154'),
('20141009085434'),
('20141010092216'),
('20141014093930'),
('20141014151854'),
('20141015154459'),
('20141022085115'),
('20141024123911'),
('20141027115724'),
('20141027152441'),
('20141030083024'),
('20141030151917'),
('20141030155602'),
('20141030191916'),
('20141031114254'),
('20141031143904'),
('20141103182351'),
('20141104085807'),
('20141104152207'),
('20141104173509'),
('20141106175808'),
('20141111015036'),
('20141113210801'),
('20141113225700'),
('20141117110557'),
('20141118171203'),
('20141119172040'),
('20141119172504'),
('20141121125857'),
('20141126172417'),
('20141128151406'),
('20141128202300'),
('20141128233552'),
('20141205151415'),
('20141209132602'),
('20141210105928'),
('20141212003040'),
('20141216115456'),
('20141216144129'),
('20141218124439'),
('20141218133324'),
('20141218195929'),
('20141222104840'),
('20141222150857'),
('20141227164106'),
('20141227213904'),
('20141228224302'),
('20150106011659'),
('20150106125840'),
('20150112122356'),
('20150115134235'),
('20150115214737'),
('20150115235756'),
('20150120102141'),
('20150121223503'),
('20150124200539'),
('20150126175206'),
('20150126181017'),
('20150126234232'),
('20150203142322'),
('20150204194512'),
('20150205220205'),
('20150210213207'),
('20150210221343'),
('20150210223034'),
('20150210223417'),
('20150210230952'),
('20150210231640'),
('20150218013352'),
('20150218095625'),
('20150219033506'),
('20150219033928'),
('20150220014208'),
('20150224223602'),
('20150305171421'),
('20150305221854'),
('20150305222300'),
('20150309210159'),
('20150311002942'),
('20150312173014'),
('20150312174534'),
('20150323183700'),
('20150323185859'),
('20150323231441'),
('20150330215326'),
('20150331192824'),
('20150331192932'),
('20150403175800'),
('20150407201235'),
('20150408003109'),
('20150408005324'),
('20150408182212'),
('20150408190530'),
('20150408230900'),
('20150410023316'),
('20150413202608'),
('20150413212447'),
('20150413215345'),
('20150414191451'),
('20150415013257'),
('20150416012140'),
('20150416193400'),
('20150417062934'),
('20150420163217'),
('20150420230950'),
('20150422095514'),
('20150427215732'),
('20150429211013'),
('20150429211518'),
('20150504095154'),
('20150507005757'),
('20150507223159'),
('20150519001057'),
('20150531192730'),
('20150531192834'),
('20150531203502'),
('20150609192939'),
('20150610223310'),
('20150622210151'),
('20150622214906'),
('20150623161328'),
('20150625084528'),
('20150625133830'),
('20150625142801'),
('20150625220913'),
('20150706213802'),
('20150707234534'),
('20150708142126'),
('20150710221428'),
('20150713082701'),
('20150714002034'),
('20150716170318'),
('20150720062027'),
('20150722000430'),
('20150722000755'),
('20150722001249'),
('20150724200550'),
('20150729234947'),
('20150730012420'),
('20150730200828'),
('20150730203234'),
('20150730233434'),
('20150801232810'),
('20150802123819'),
('20150804195852'),
('20150805010617'),
('20150805180423'),
('20150805201415'),
('20150805203056'),
('20150805211527'),
('20150805211551'),
('20150806175805'),
('20150807083004'),
('20150807093929'),
('20150807093930'),
('20150807093931'),
('20150807093932'),
('20150807093933'),
('20150811082850'),
('20150812214306'),
('20150812215331'),
('20150813172403'),
('20150818013713'),
('20150818085634'),
('20150819162440'),
('20150820235945'),
('20150824143600'),
('20150825220857'),
('20150828203716'),
('20150829020312'),
('20150831222018'),
('20150831224444'),
('20150901211217'),
('20150904190235'),
('20150908073258'),
('20150908095158'),
('20150908120929'),
('20150910102828'),
('20150910135525'),
('20150911151217'),
('20150915065634'),
('20150918031748'),
('20150922092214'),
('20150922092405'),
('20150922092524'),
('20151006081729'),
('20151008152755'),
('20151008183848'),
('20151009082625'),
('20151009133509'),
('20151009163350'),
('20151014064248'),
('20151016062615'),
('20151022213403'),
('20151026231609'),
('20151026233709'),
('20151027153715'),
('20151028073251'),
('20151030204845'),
('20151103002221'),
('20151103045755'),
('20151104211640'),
('20151105194813'),
('20151112075910'),
('20151112141354'),
('20151113012209'),
('20151114011955'),
('20151118105923'),
('20151118112238'),
('20151202204354'),
('20151203233628'),
('20151209222249'),
('20151218022356'),
('20151219001713'),
('20151228111810'),
('20151228153550'),
('20151230115403'),
('20160108204927'),
('20160114042456'),
('20160118230510'),
('20160119001151'),
('20160202133748'),
('20160202173838'),
('20160218163326'),
('20160224195146'),
('20160224195150'),
('20160224222419'),
('20160224230909'),
('20160224231406'),
('20160224234435'),
('20160224234811'),
('20160226015703'),
('20160227095032'),
('20160229185649'),
('20160301192617'),
('20160304021426'),
('20160304151027'),
('20160307142039'),
('20160307152236'),
('20160307170926'),
('20160308025429'),
('20160308201805'),
('20160310130645'),
('20160311021056'),
('20160315215429'),
('20160318175125'),
('20160321150952'),
('20160322223015'),
('20160322235632'),
('20160322235706'),
('20160322235846'),
('20160323083742'),
('20160323192820'),
('20160324182619'),
('20160331182528'),
('20160402001700'),
('20160404225715'),
('20160406154533'),
('20160407123618'),
('20160407181048'),
('20160412183828'),
('20160412203223'),
('20160415002214'),
('20160419214330'),
('20160419235458'),
('20160420032313'),
('20160420220138'),
('20160422030004'),
('20160422043004'),
('20160502191106'),
('20160502195750'),
('20160503152025'),
('20160503152949'),
('20160503173128'),
('20160504134459'),
('20160514232838'),
('20160514233924'),
('20160516065809'),
('20160516235807'),
('20160517053451'),
('20160524124013'),
('20160526153637'),
('20160526154239'),
('20160531150955'),
('20160601144742'),
('20160602183306'),
('20160602183351'),
('20160602183414'),
('20160602183807'),
('20160602195310'),
('20160602195325'),
('20160602195339'),
('20160606143105'),
('20160606235527'),
('20160607005821'),
('20160607121458'),
('20160620225350'),
('20160621144849'),
('20160621171944'),
('20160624181156'),
('20160626161923'),
('20160630202535'),
('20160702003626'),
('20160702011339'),
('20160706223927'),
('20160712130009'),
('20160714093317'),
('20160715081811'),
('20160720113019'),
('20160720121409'),
('20160720121530'),
('20160802142154'),
('20160802225628'),
('20160803142923'),
('20160803173208'),
('20160805125049'),
('20160811155716'),
('20160811185743'),
('20160811193151'),
('20160812182944'),
('20160823203858'),
('20160823230129'),
('20160824121603'),
('20160824134023'),
('20160831200828'),
('20160902091539'),
('20160902165855'),
('20160912225315'),
('20160919132207'),
('20160920212048'),
('20160922163428'),
('20160930192340'),
('20161004193907'),
('20161007085231'),
('20161012170736'),
('20161013114200'),
('20161014225534'),
('20161021083046'),
('20161025101222'),
('20161026195945'),
('20161103124632'),
('20161103220347'),
('20161111101935'),
('20161114092407'),
('20161129123459'),
('20161130153059'),
('20161202141805'),
('20161206124931'),
('20161214010115'),
('20161221030207'),
('20161221233134'),
('20170110121628'),
('20170110155016'),
('20170111202502'),
('20170111203747'),
('20170111221613'),
('20170117214220'),
('20170126200226'),
('20170131094900'),
('20170131095043'),
('20170131095221'),
('20170131224913'),
('20170202210052'),
('20170203130522'),
('20170205142434'),
('20170206130644'),
('20170206160013'),
('20170206175117'),
('20170206231700'),
('20170212011501'),
('20170213220425'),
('20170213235555'),
('20170215100500'),
('20170215224612'),
('20170217110945'),
('20170220140125'),
('20170225120508'),
('20170303093041'),
('20170307063545'),
('20170307154458'),
('20170307161942'),
('20170308163654'),
('20170309012131'),
('20170310144108'),
('20170310162100'),
('20170311020316'),
('20170313203212'),
('20170314001012'),
('20170314165353'),
('20170319190009'),
('20170322010146'),
('20170322183838'),
('20170322211512'),
('20170328085810'),
('20170331134859'),
('20170331165347'),
('20170401082057'),
('20170406152243'),
('20170406173656'),
('20170407120526'),
('20170407142707'),
('20170412163903'),
('20170413181612'),
('20170417102347'),
('20170420150322'),
('20170425095924'),
('20170427210701'),
('20170501103918'),
('20170502100853'),
('20170504092549'),
('20170504230018'),
('20170505105048'),
('20170505105258'),
('20170510133715'),
('20170517154041'),
('20170517195258'),
('20170519014548'),
('20170522170530'),
('20170522175524'),
('20170522191344'),
('20170522194451'),
('20170523174447'),
('20170524134920'),
('20170524201335'),
('20170525064024'),
('20170525103722'),
('20170526233139'),
('20170529124727'),
('20170530054540'),
('20170530091229'),
('20170530173631'),
('20170530182401'),
('20170530192215'),
('20170531054635'),
('20170601032021'),
('20170605141458'),
('20170605153410'),
('20170606202048'),
('20170608173217'),
('20170608195504'),
('20170608202423'),
('20170614091009'),
('20170621214840'),
('20170622071538'),
('20170630085358'),
('20170706135858'),
('20170710143900'),
('20170710234043'),
('20170711102050'),
('20170711115537'),
('20170712113049'),
('20170712115322'),
('20170712144759'),
('20170713104133'),
('20170713113325'),
('20170717092300'),
('20170717205133'),
('20170724222515'),
('20170724222516'),
('20170725074811'),
('20170727083621'),
('20170727083824'),
('20170728070557'),
('20170731063739'),
('20170731133354'),
('20170803081110'),
('20170803174852'),
('20170803230932'),
('20170803231141'),
('20170808091856'),
('20170808122224'),
('20170808164005'),
('20170809004811'),
('20170810152703'),
('20170813085653'),
('20170813094655'),
('20170813102850'),
('20170814064554'),
('20170815065830'),
('20170815102353'),
('20170815103211'),
('20170816093124'),
('20170816143907'),
('20170817102423'),
('20170817111722'),
('20170818090603'),
('20170822234655'),
('20170823105215'),
('20170825082201'),
('20170825215442'),
('20170825221944'),
('20170825222933'),
('20170825224852'),
('20170828142100'),
('20170828192443'),
('20170828220729'),
('20170828221334'),
('20170829143110'),
('20170829232430'),
('20170829233752'),
('20170829235921'),
('20170830124045'),
('20170830170306'),
('20170902134210'),
('20170902135312'),
('20170905181049'),
('20170906135516'),
('20170906183054'),
('20170907134905'),
('20170907191636'),
('20170907224300'),
('20170908053742'),
('20170908090914'),
('20170910084241'),
('20170910085033'),
('20170910090949'),
('20170911125450'),
('20170911143641'),
('20170911201624'),
('20170912070531'),
('20170912082529'),
('20170912155313'),
('20170912193500'),
('20170912194432'),
('20170913093433'),
('20170913104607'),
('20170913165340'),
('20170914123737'),
('20170914130712'),
('20170916053131'),
('20170918182926'),
('20170921072800'),
('20170921083401'),
('20170921083555'),
('20170922140832'),
('20170926223035'),
('20170927093930'),
('20170928003045'),
('20170928083309'),
('20170928202505'),
('20170929030153'),
('20171001175800'),
('20171003072130'),
('20171003072751'),
('20171005180101'),
('20171006072900'),
('20171006120138'),
('20171006131048'),
('20171006131931'),
('20171009081432'),
('20171009084739'),
('20171010083423'),
('20171011105711'),
('20171012090718'),
('20171012135004'),
('20171012161744'),
('20171013075743'),
('20171013160613'),
('20171018081143'),
('20171018081405'),
('20171020234701'),
('20171023112304'),
('20171023112753'),
('20171024181154'),
('20171024181427'),
('20171025101247'),
('20171026115825'),
('20171030121119'),
('20171030210705'),
('20171031095508'),
('20171101121235'),
('20171101130145'),
('20171101131008'),
('20171103130840'),
('20171107070847'),
('20171107095522'),
('20171108092151'),
('20171108123414'),
('20171108132706'),
('20171108151243'),
('20171114122823'),
('20171114130043'),
('20171114194312'),
('20171114222949'),
('20171116131619'),
('20171116222512'),
('20171117095912'),
('20171117124447'),
('20171121114527'),
('20171121193837'),
('20171122131411'),
('20171123152051'),
('20171123161525'),
('20171127155040'),
('20171128060809'),
('20171129140610'),
('20171130163018'),
('20171130164038'),
('20171204101230'),
('20171204115945'),
('20171204142702'),
('20171205121324'),
('20171205122016'),
('20171208092142'),
('20171208124940'),
('20171212085612'),
('20171212095215'),
('20171213170726'),
('20171218104523'),
('20171219132918'),
('20171220112217'),
('20171220112651'),
('20171221132522'),
('20171222074208'),
('20171222100109'),
('20171226164838'),
('20171226171759'),
('20171226171948'),
('20171227161928'),
('20171228083853'),
('20171228094040'),
('20171228134859'),
('20180102123438'),
('20180102125858'),
('20180103071319'),
('20180103083154'),
('20180104143008'),
('20180105081550'),
('20180105092643'),
('20180105120215'),
('20180108082935'),
('20180108223540'),
('20180109075400'),
('20180110084647'),
('20180111103046'),
('20180112130908'),
('20180113113252'),
('20180113113821'),
('20180113185931'),
('20180115091627'),
('20180116150649'),
('20180117124056'),
('20180117131618'),
('20180117163655'),
('20180119193013'),
('20180125224441'),
('20180202114109'),
('20180202114704'),
('20180205125707'),
('20180207080137'),
('20180209084714'),
('20180209181030'),
('20180220153742'),
('20180221180258'),
('20180221185259'),
('20180221210551'),
('20180221233339'),
('20180222115820'),
('20180222130316'),
('20180222180502'),
('20180223054734'),
('20180226211319'),
('20180226214501'),
('20180226214536'),
('20180226214600'),
('20180226214621'),
('20180226214754'),
('20180226214836'),
('20180227194904'),
('20180227200841'),
('20180227200853'),
('20180302205015'),
('20180304121104'),
('20180305120016'),
('20180305133902'),
('20180305145644'),
('20180306114523'),
('20180306153055'),
('20180306163906'),
('20180308105903'),
('20180308182146'),
('20180308195631'),
('20180309122151'),
('20180309122548'),
('20180309123035'),
('20180312115647'),
('20180312202451'),
('20180313215800'),
('20180314084014'),
('20180314223155'),
('20180315215504'),
('20180316214754'),
('20180316220005'),
('20180320135503'),
('20180320140007'),
('20180320174804'),
('20180321142901'),
('20180321143549'),
('20180323192548'),
('20180325134225'),
('20180326084329'),
('20180326084917'),
('20180326112429'),
('20180326113136'),
('20180328134050'),
('20180329095344'),
('20180329172729'),
('20180330062824'),
('20180330083331'),
('20180401093829'),
('20180401102947'),
('20180405165313'),
('20180405165834'),
('20180406061531'),
('20180406061840'),
('20180406062531'),
('20180406062807'),
('20180410051503'),
('20180411065831'),
('20180412070346'),
('20180413183823'),
('20180416193838'),
('20180417221939'),
('20180418085552'),
('20180419152102'),
('20180419203414'),
('20180420143807'),
('20180424161230'),
('20180426101753'),
('20180427090915'),
('20180428082206'),
('20180501113147'),
('20180501180330'),
('20180501192813'),
('20180503101044'),
('20180503114055'),
('20180504091436'),
('20180508075356'),
('20180508104714'),
('20180509053626'),
('20180509054622'),
('20180509091131'),
('20180514080917'),
('20180515104218'),
('20180515182626'),
('20180516173606'),
('20180520091954'),
('20180520132145'),
('20180522101600'),
('20180522174920'),
('20180524084133'),
('20180524160855'),
('20180528122021'),
('20180529151129'),
('20180530133919'),
('20180531124118'),
('20180601152320'),
('20180604211445'),
('20180605054924'),
('20180605191930'),
('20180606072745'),
('20180606160113'),
('20180612093450'),
('20180612110418'),
('20180613130149'),
('20180613172516'),
('20180614082024'),
('20180617144336'),
('20180618114639'),
('20180621052942'),
('20180622143534'),
('20180625225523'),
('20180625230325'),
('20180626185415'),
('20180626202437'),
('20180628211613'),
('20180629233117'),
('20180708170351'),
('20180709145330'),
('20180711063733'),
('20180711064250'),
('20180711072730'),
('20180711093310'),
('20180711120821'),
('20180717084839'),
('20180717173531'),
('20180717173702'),
('20180717173900'),
('20180717174110'),
('20180717174217'),
('20180718111252'),
('20180720062503'),
('20180720112959'),
('20180724131058'),
('20180724132750'),
('20180726102028'),
('20180727131326'),
('20180729190647'),
('20180806154056'),
('20180806164753'),
('20180807062749'),
('20180807084531'),
('20180807201916'),
('20180808190601'),
('20180812063653'),
('20180813113804'),
('20180814063857'),
('20180819144328'),
('20180820083023'),
('20180820095334'),
('20180820101710'),
('20180820121712'),
('20180820175319'),
('20180821134001'),
('20180822230605'),
('20180823151128'),
('20180824120719'),
('20180827134227'),
('20180827180645'),
('20180829102112'),
('20180830110310'),
('20180831142830'),
('20180903134306'),
('20180905141728'),
('20180906131218'),
('20180907103827'),
('20180911195734'),
('20180912115237'),
('20180914103222'),
('20180915133124'),
('20180919133535'),
('20180919144315'),
('20180920100959'),
('20180921152355'),
('20180921152604'),
('20180924093312'),
('20180925154353'),
('20180926064739'),
('20180926112842'),
('20180926124728'),
('20180926154437'),
('20180928120154'),
('20181004141847'),
('20181019044505'),
('20181030124117'),
('20181030160649'),
('20181101122020'),
('20181105104238'),
('20181105161114'),
('20181108202746'),
('20181109064748'),
('20181109133457'),
('20181112075700'),
('20181115202800'),
('20181116154524'),
('20181119143303'),
('20181122122158'),
('20181123101446'),
('20181123154314'),
('20181126153331'),
('20181217133655'),
('20181217161523'),
('20181217163811'),
('20181219002842'),
('20181219191149'),
('20181224080930'),
('20181224155458'),
('20181224254453'),
('20181227100954'),
('20181230133329'),
('20190103045855'),
('20190104043629'),
('20190104100519'),
('20190105015058'),
('20190105042825'),
('20190105044941'),
('20190105060523'),
('20190105062029'),
('20190105072526'),
('20190106121235'),
('20190108085351'),
('20190109025508'),
('20190114055903'),
('20190115143728'),
('20190116071805'),
('20190116172602'),
('20190117034953'),
('20190117042848'),
('20190124165634'),
('20190124210826'),
('20190125145510'),
('20190128111513'),
('20190131042134'),
('20190201113513'),
('20190206032027'),
('20190206185304'),
('20190207020226'),
('20190213064309'),
('20190213140525'),
('20190214121752'),
('20190214172813'),
('20190214180134'),
('20190214180342'),
('20190215095242'),
('20190216083612'),
('20190219111030'),
('20190219131722'),
('20190220130720'),
('20190220140500'),
('20190220140512'),
('20190220193115'),
('20190221105519'),
('20190222071558'),
('20190222102633'),
('20190222124643'),
('20190222125957'),
('20190225084527'),
('20190225111909'),
('20190225121101'),
('20190225124935'),
('20190225131106'),
('20190225131744'),
('20190225271042'),
('20190227081403'),
('20190227194053'),
('20190228140357'),
('20190301122006'),
('20190302075613'),
('20190306094415'),
('20190306095452'),
('20190306100858'),
('20190306102729'),
('20190307050035'),
('20190307133832'),
('20190309130618'),
('20190312132609'),
('20190313082555'),
('20190313172504'),
('20190318083527'),
('20190318085850'),
('20190318102832'),
('20190326053235'),
('20190327063235'),
('20190327092632'),
('20190327131226'),
('20190329155854'),
('20190402084736'),
('20190402133356'),
('20190403132936'),
('20190409102819'),
('20190410064524'),
('20190422141941'),
('20190425122147'),
('20190425123803'),
('20190430133248'),
('20190508143339'),
('20190509140207'),
('20190509140457'),
('20190513084318'),
('20190513163207'),
('20190513165250'),
('20190514065540'),
('20190520120617'),
('20190523131941'),
('20190523165028'),
('20190527173058'),
('20190528070511'),
('20190529085737'),
('20190529123646'),
('20190530194337'),
('20190530202629'),
('20190603101932'),
('20190604074323'),
('20190605132928'),
('20190610132041'),
('20190611064530'),
('20190614085902'),
('20190614113205'),
('20190614152001'),
('20190619164240'),
('20190623101015'),
('20190624140707'),
('20190626090237'),
('20190704063515'),
('20190705080525'),
('20190707132909'),
('20190711165743'),
('20190712083412'),
('20190715121112'),
('20190715143050'),
('20190715173845'),
('20190717135234'),
('20190718015721'),
('20190719020112'),
('20190722063950'),
('20190722114845'),
('20190723085034'),
('20190724141253'),
('20190726095058'),
('20190807181124'),
('20190807182043'),
('20190808161351'),
('20190809100518'),
('20190811174619'),
('20190812130552'),
('20190813064317'),
('20190817180913'),
('20190820165547'),
('20190822084753'),
('20190827093525'),
('20190827094724'),
('20190827094750'),
('20190830171021'),
('20190830171716'),
('20190905064559'),
('20190906181556'),
('20190909181300'),
('20190911081225'),
('20190918172812'),
('20190919102912'),
('20190923115633'),
('20190924143036'),
('20190928153358'),
('20191004180409'),
('20191009052851'),
('20191009053115'),
('20191014100359'),
('20191017070347'),
('20191017170701'),
('20191018120107'),
('20191021081654'),
('20191021095843'),
('20191023095545'),
('20191024102419'),
('20191025115917'),
('20191105090810'),
('20191108160509'),
('20191111120928'),
('20191124213012'),
('20191127142914'),
('20191212162011'),
('20200113073615'),
('20200113073616'),
('20200113101344'),
('20200114113030'),
('20200114115244'),
('20200115151846'),
('20200120091328'),
('20200120091329'),
('20200126151356'),
('20200128091206'),
('20200201041840'),
('20200210101957'),
('20200210102602'),
('20200210104120'),
('20200210113335'),
('20200210113357'),
('20200210113406'),
('20200210113703'),
('20200221151928'),
('20200305134611'),
('20200306133549'),
('20200306133610'),
('20200306133631'),
('20200306133654'),
('20200307190447'),
('20200310151516'),
('20200318075101'),
('20200318075542'),
('20200318123039'),
('20200318133009'),
('20200406113801'),
('20200415090008'),
('20200430200648'),
('20200506074431'),
('20200512203445'),
('20200515100858'),
('20200519031052'),
('20200527073722'),
('20200602041155'),
('20200605072902'),
('20200618103717'),
('20200703000418'),
('20200714234004'),
('20200716223744'),
('20200724143557'),
('20200729205854'),
('20200729215034'),
('20200729222752'),
('20200804142714'),
('20200811191442'),
('20200813182312'),
('20200819174007'),
('20200820145809'),
('20200820151203'),
('20200821110109'),
('20200824172136'),
('20200826194139'),
('20200831061404'),
('20200831061406'),
('20200902180113'),
('20200903201625'),
('20200914093824'),
('20200914095218'),
('20200918154846'),
('20200921230830'),
('20200924144357'),
('20200924200209'),
('20200924200727'),
('20200927152347'),
('20200928145603'),
('20200928160833'),
('20200929155740'),
('20201006161621'),
('20201006192333'),
('20201007202157'),
('20201016185420'),
('20201026162814'),
('20201029182839'),
('20201110214926'),
('20201113012155'),
('20201113013542'),
('20201116180344'),
('20201121202825'),
('20201124150357'),
('20201124190712'),
('20201126015811'),
('20201126022316'),
('20201205164654'),
('20201205170436'),
('20201207140123'),
('20201207203523'),
('20201210094854'),
('20201213105814'),
('20201215145610'),
('20201216133403'),
('20201221165427'),
('20201222165105'),
('20201224115804'),
('20210104204218'),
('20210112235821'),
('20210113113857'),
('20210119203309'),
('20210122090745'),
('20210126231057'),
('20210129143215'),
('20210129150534'),
('20210130160521'),
('20210202102931'),
('20210202204416'),
('20210202205051'),
('20210204173800'),
('20210205124244'),
('20210207160838'),
('20210208050402'),
('20210208064539'),
('20210208090425'),
('20210208103505'),
('20210210204724'),
('20210213173622'),
('20210216195545'),
('20210217202741'),
('20210217212053'),
('20210222190923'),
('20210225093215'),
('20210301103504'),
('20210304015624'),
('20210304095816'),
('20210304100830'),
('20210304220332'),
('20210308213823'),
('20210316125852'),
('20210316172816'),
('20210318004519'),
('20210318202800'),
('20210325202015'),
('20210330002131'),
('20210331183941'),
('20210401215622'),
('20210401220529'),
('20210407124659'),
('20210407170749'),
('20210408142457'),
('20210414073854'),
('20210415063650'),
('20210415110524'),
('20210423115232'),
('20210426112844'),
('20210428134009'),
('20210501070721'),
('20210504125751'),
('20210505104527'),
('20210511214725'),
('20210517204500'),
('20210524105651'),
('20210524230606'),
('20210525082301'),
('20210526102316'),
('20210527070057'),
('20210527222039'),
('20210530003241'),
('20210531140029'),
('20210601062453'),
('20210603082912'),
('20210603123842'),
('20210603193939'),
('20210604171723'),
('20210607084729'),
('20210607193811'),
('20210607212329'),
('20210608225516'),
('20210608234242'),
('20210610075852'),
('20210610221946'),
('20210614183942'),
('20210614220735'),
('20210619012209'),
('20210622225158'),
('20210622225255'),
('20210624021801'),
('20210624023916'),
('20210625185657'),
('20210627221823'),
('20210630175515'),
('20210630233716'),
('20210707202314'),
('20210712103435'),
('20210714133623'),
('20210715054503'),
('20210715110143'),
('20210715113016'),
('20210716062832'),
('20210719061412'),
('20210720212941'),
('20210722102836'),
('20210722164209'),
('20210722164852'),
('20210722283535'),
('20210727193516'),
('20210729050405'),
('20210729200705'),
('20210730163902'),
('20210730175747'),
('20210803073645'),
('20210803162815'),
('20210805192702'),
('20210806061958'),
('20210806090145'),
('20210810203351'),
('20210817182733'),
('20210819180818'),
('20210819181540'),
('20210819183025'),
('20210825214554'),
('20210830144834'),
('20210831073530'),
('20210831073904'),
('20210831173735'),
('20210901105637'),
('20210903190202'),
('20210913224257'),
('20210915150624'),
('20210915203905'),
('20210917213617'),
('20210919171025'),
('20210924152424'),
('20211005180913'),
('20211005182458'),
('20211005193750'),
('20211006194156'),
('20211013235143'),
('20211019155151'),
('20211022131131'),
('20211026113017'),
('20211026152027'),
('20211027104111'),
('20211028060508'),
('20211029173342'),
('20211102085638'),
('20211117204211'),
('20211122114351'),
('20211123201108'),
('20211123210135'),
('20211125191708'),
('20211128015812'),
('20211129151652'),
('20211130235528'),
('20211202074524'),
('20211202155540'),
('20211209210516'),
('20220107213139'),
('20220109160222'),
('20220111212155'),
('20220113111038'),
('20220117152312'),
('20220117152755'),
('20220117164644'),
('20220119063219'),
('20220119063453'),
('20220119064000'),
('20220119064055'),
('20220121105558'),
('20220126023856'),
('20220126124406'),
('20220127115836'),
('20220127115958'),
('20220127150547'),
('20220131120732'),
('20220131160152'),
('20220202093623'),
('20220209085512'),
('20220210093534'),
('20220210100540'),
('20220215163214'),
('20220222094546'),
('20220222210758'),
('20220225162343'),
('20220225210004'),
('20220228143945'),
('20220301110205'),
('20220301110652'),
('20220301170646'),
('20220315161052'),
('20220321164346'),
('20220321172247'),
('20220323160556'),
('20220328154739'),
('20220329063656'),
('20220329120522'),
('20220329172418'),
('20220401145550'),
('20220402001331'),
('20220402002801'),
('20220405201545'),
('20220405202009'),
('20220407095205'),
('20220407170158'),
('20220414111616'),
('20220414132932'),
('20220414230308'),
('20220417144607'),
('20220418104943'),
('20220426044305'),
('20220503102844'),
('20220505081315'),
('20220523052459'),
('20220526110337'),
('20220530053523'),
('20220603211632'),
('20220607122214'),
('20220607162142'),
('20220609131122'),
('20220609134903'),
('20220610131239'),
('20220616050656'),
('20220617114641'),
('20220617114929'),
('20220622123851'),
('20220627082421'),
('20220627083700'),
('20220627093853'),
('20220627140551'),
('20220628172134'),
('20220629040105'),
('20220701154856'),
('20220706062252'),
('20220706152738'),
('20220714213247'),
('20220719070356'),
('20220722073318'),
('20220725160953'),
('20220727160303'),
('20220805093605'),
('20220808150428'),
('20220809122550'),
('20220810003649'),
('20220810161435'),
('20220811113912'),
('20220819211712'),
('20220821142343'),
('20220822144132'),
('20220823124430'),
('20220824162541'),
('20220829030919'),
('20220829180835'),
('20220830111630'),
('20220830185748'),
('20220831115033'),
('20220901084148'),
('20220902233345'),
('20220902235216'),
('20220906193012'),
('20220906223744'),
('20220908121840'),
('20220909184054'),
('20220909192132'),
('20220912105039'),
('20220913084109'),
('20220915024548'),
('20220915070423'),
('20220919050418'),
('20220920064343'),
('20220920065458'),
('20220920120823'),
('20220921045529'),
('20220922084620'),
('20220922095513'),
('20220922104501'),
('20220926132758'),
('20220926194338'),
('20220927091754'),
('20220927114950'),
('20220928145528'),
('20220928153601'),
('20220928170300'),
('20220929145822'),
('20220929151941'),
('20220930140405'),
('20220930152006'),
('20221004105539'),
('20221004112236'),
('20221004112415'),
('20221004142448'),
('20221004182714'),
('20221005082908'),
('20221005092605'),
('20221006125906'),
('20221011174435'),
('20221012041407'),
('20221012082233'),
('20221012095022'),
('20221012102828'),
('20221012110704'),
('20221013083637'),
('20221013100711'),
('20221014081947'),
('20221014153646'),
('20221017095104'),
('20221017145507'),
('20221018165640'),
('20221018182546'),
('20221019111806'),
('20221019141505'),
('20221024180522'),
('20221025102248'),
('20221025194808'),
('20221025215529'),
('20221026143953'),
('20221026150056'),
('20221027103018'),
('20221027152222'),
('20221028082650'),
('20221028142003'),
('20221031052133'),
('20221101091456'),
('20221101102008'),
('20221101134950'),
('20221102033909'),
('20221102034206'),
('20221103020556'),
('20221103020945'),
('20221103122248'),
('20221104125550'),
('20221104140943'),
('20221108100512'),
('20221108111801'),
('20221109095946'),
('20221109113657'),
('20221109132903'),
('20221109143851'),
('20221109150007'),
('20221110134401'),
('20221111054741'),
('20221111193847'),
('20221115061647'),
('20221116112408'),
('20221116114417'),
('20221116115015'),
('20221116115409'),
('20221116121938'),
('20221116122451'),
('20221116123620'),
('20221116144903'),
('20221117031831'),
('20221117211830'),
('20221117215207'),
('20221117215221'),
('20221118072932'),
('20221118190107'),
('20221122095305'),
('20221122095912'),
('20221122102026'),
('20221123080104'),
('20221124042656'),
('20221124064042');


