class AddUniqueIndexes < ActiveRecord::Migration
  class WrapPostVote < ApplicationRecord
    self.table_name = 'post_votes'
  end

  class WrapCommentVote < ApplicationRecord
    self.table_name = 'comment_votes'
  end

  class WrapSubscriber < ApplicationRecord
    self.table_name = 'subscribers'
  end

  def change
    WrapPostVote.group(:user_id, :post_id).having('count(*) > 1').pluck(:user_id, :post_id, 'count(*)').each do |(user_id, post_id, count)|
      WrapPostVote.where(user_id: user_id, post_id: post_id).order('id ASC').limit(count - 1).destroy_all
    end

    add_index :post_votes, %i(user_id post_id), unique: true

    WrapCommentVote.group(:user_id, :comment_id).having('count(*) > 1').pluck(:user_id, :comment_id, 'count(*)').each do |(user_id, comment_id, count)|
      WrapCommentVote.where(user_id: user_id, comment_id: comment_id).order('id ASC').limit(count - 1).destroy_all
    end

    add_index :comment_votes, %i(user_id comment_id), unique: true

    WrapSubscriber.group(:email).having('count(*) > 1').pluck(:email, 'count(*)').each do |(email, count)|
      WrapSubscriber.where(email: email).order('id ASC').limit(count - 1).destroy_all
    end

    add_index :subscribers, %i(email), unique: true

    add_index :collections, %i(user_id name), unique: true
    add_index :product_makers, %i(user_id post_id), unique: true

    remove_index :users, %(username)
    add_index :users, %i(username), unique: true
  end
end
