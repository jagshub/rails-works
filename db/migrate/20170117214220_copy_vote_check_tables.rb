class CopyVoteCheckTables < ActiveRecord::Migration
  def up
    create_table :vote_infos do |t|
      t.references :vote, null: false
      t.inet :request_ip
      t.text :referer
      t.references :oauth_application
      t.integer :visit_duration, null: true
    end

    create_table :vote_check_results do |t|
      t.references :vote, null: false
      t.integer :check, null: false
      t.integer :spam_score, default: 0, null: false
      t.integer :vote_ring_score, default: 0, null: false
    end

    execute <<-SQL
      WITH remapped_vote_infos AS (
        SELECT
          post_vote_infos.id,
          votes.id AS vote_id,
          post_vote_infos.request_ip,
          post_vote_infos.referer,
          post_vote_infos.oauth_application_id,
          post_vote_infos.visit_duration
        FROM post_vote_infos
        INNER JOIN post_votes ON post_votes.id = post_vote_infos.post_vote_id
        INNER JOIN votes ON votes.subject_type = 'Post' AND votes.subject_id = post_votes.post_id AND votes.user_id = post_votes.user_id
      )
      INSERT INTO vote_infos (id, vote_id, request_ip, referer, oauth_application_id, visit_duration)
      SELECT * FROM remapped_vote_infos;
    SQL

    execute <<-SQL
      WITH remapped_vote_check_results AS (
        SELECT
          post_vote_check_results.id,
          votes.id AS vote_id,
          post_vote_check_results.check,
          post_vote_check_results.spam_score,
          post_vote_check_results.vote_ring_score
        FROM post_vote_check_results
        INNER JOIN post_votes ON post_votes.id = post_vote_check_results.post_vote_id
        INNER JOIN votes ON votes.subject_type = 'Post' AND votes.subject_id = post_votes.post_id AND votes.user_id = post_votes.user_id
      )
      INSERT INTO vote_check_results (id, vote_id, "check", spam_score, vote_ring_score)
      SELECT * FROM remapped_vote_check_results;
    SQL

    add_index :vote_infos, :vote_id, unique: true
    add_index :vote_check_results, [:vote_id, :check], unique: true
  end

  def down
    drop_table :vote_infos
    drop_table :vote_check_results
  end
end
