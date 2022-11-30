require 'rails_helper'

describe Mutations::CreateVote do
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

  it 'upvote a post without login throws error' do
    expect { call(current_user: nil, post_id: post.id) }.to raise_error GraphQL::ExecutionError, 'You need to authenticate to perform this action'
  end

  it 'upvote a post after login creats vote' do
    expect{(call(current_user: user, post_id: post.id))}.to increment{ Vote.count }
  end

  it 'upvoting twice by same user should not create new vote' do
    expect{(call(current_user: user, post_id: post.id))}.to increment{ Vote.count }
    expect{(call(current_user: user, post_id: post.id))}.to change{ Vote.count }.by(0)
  end

  it 'check vote count after upvote by 2 users ' do
    expect{(call(current_user: user, post_id: post.id))}.to increment{ Vote.count }
    expect{(call(current_user: second_user, post_id: post.id))}.to increment{ Vote.count }
  end

end
