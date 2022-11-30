require 'rails_helper'

describe Mutations::RemoveVote do
  let(:object) { :not_used }
  let(:user) { create :user, name: 'name' }
  let(:vote_by_user1) { create :vote, user: user, post: post }
  let(:second_user) { create :user, name: 'name' }
  let(:vote_by_second_user) { create :vote, user: second_user, post: post }
  let(:post) { create :post, user: user }

  def call(current_user:, context: {}, **args)
    context = Utils::Context.new(
      query: OpenStruct.new(schema: KittynewsSchema),
      values: context.merge(current_user: current_user),
      object: nil,
      )
    described_class.new(object: nil, context: context, field: nil).resolve(args)
  end

  it 'downvote a post without login throws error' do
    expect { call(current_user: nil, post_id: post.id) }.to raise_error GraphQL::ExecutionError, 'You need to authenticate to perform this action'
  end

  it 'down voting a post after login should remove the vote' do
    expect { vote_by_user1 }.to change { Vote.count }.by(1)
    expect { vote_by_second_user }.to change { Vote.count }.by(1)
    expect{(call(current_user: user, post_id: post.id))}.to decrement{ Vote.count }
  end

  it 'verify down voting same post twice by same user' do
    expect { vote_by_user1 }.to change { Vote.count }.by(1)
    expect { vote_by_second_user }.to change { Vote.count }.by(1)
    expect{(call(current_user: user, post_id: post.id))}.to decrement{ Vote.count }
    expect{(call(current_user: user, post_id: post.id))}.to change{ Vote.count }.by(0)
  end

  it 'check vote count after downvoting by 2 users ' do
    expect { vote_by_user1 }.to change { Vote.count }.by(1)
    expect { vote_by_second_user }.to change { Vote.count }.by(1)
    expect{(call(current_user: user, post_id: post.id))}.to decrement{ Vote.count }
    expect{(call(current_user: second_user, post_id: post.id))}.to decrement{ Vote.count }
  end
end
