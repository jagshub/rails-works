# frozen_string_literal: true

class ShareableImageController < ApplicationController
  def show
    comment = Comment.find(params[:comment_id])
    redirect_to Sharing.image_for(comment)
  end

  def discussion_thread
    @thread = Discussion::Thread.find(params[:id])
  end

  def change_log
    @change_log = ChangeLog::Entry.published.find_by(slug: params[:slug])
  end

  def user
    @user = User.find(params[:id])
  end

  def comment
    @comment = Comment.find(params[:id])
  end

  def collection
    @collection = Collection.find(params[:id])
  end

  def job
    @job = Job.find(params[:id])
  end

  def post_launch
    @post = Post.find(params[:id])
    @chart_data = Posts::Statistics.generate_stats_for_launch_day_chart(@post)
  end

  def products_alternatives
    @product = Product.find(params[:id])
  end

  def upcoming_event
    @upcoming_event = Upcoming::Event.find(params[:id])
  end
end
