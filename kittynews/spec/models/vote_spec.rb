require 'rails_helper'

RSpec.describe Vote, type: :model do
  describe 'Validations' do
    let(:user) {create(:user)}
    let(:post1) {create(:post)}
    let(:post2) {create(:post)}

    it 'user can vote on a post' do
      expect{(create(:vote, post_id: post1.id, user_id: user.id))}.to change{ Vote.count }.by(1)
    end

    it 'checks user can vote only once on a post' do
      expect{(create(:vote, post_id: post1.id, user_id: user.id))}.not_to raise_error
      expect{(create(:vote, post_id: post1.id, user_id: user.id))}.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
