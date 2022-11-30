require 'rails_helper'

describe Mutations::AddComment do
  let(:object) { :not_used }
  let(:user) { create :user, name: 'name' }
  let(:second_user) { create :user, name: 'name' }
  let(:post) { create :post, user: user }

  def call(current_user:, context: {}, **args)
    context = Utils::Context.new(
      query: OpenStruct.new(schema: KittynewsSchema),
      values: context.merge(current_user: current_user),
      object: nil,
      )
    described_class.new(object: nil, context: context, field: nil).resolve(args)
  end

  it 'add a comment before sign in' do
    comment_text = "new comment"
    expect { call(current_user: nil, post_id: post.id, user_id: user.id, text: comment_text) }.to raise_error GraphQL::ExecutionError, 'You need to authenticate to perform this action'
  end

  it 'add a comment after sign in' do
    comment_text = "new comment"
    expect { call(current_user: user, post_id: post.id, user_id: user.id, text: comment_text) }.to increment{ Comment.count}
  end

end
