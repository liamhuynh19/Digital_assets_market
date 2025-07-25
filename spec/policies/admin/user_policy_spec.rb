require 'rails_helper'

RSpec.describe Admin::UserPolicy do
  let(:admin) { create(:user, role: 'admin') }
  let(:seller) { create(:user, role: 'seller') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:user) { create(:user) }

  describe '#index?' do
    it "denies access to non-admin users" do
      policy = described_class.new(seller, User)
      expect(policy.index?).to be false
    end

    it "allows access to admin users" do
      policy = described_class.new(admin, User)
      expect(policy.index?).to be true
    end
  end

  %i[show? edit? update? destroy?].each do |action|
    describe "##{action}" do
      it "denies access to non-admin users" do
        policy = described_class.new(seller, user)
        expect(policy.public_send(action)).to be false
      end

      it "allows access to admin users" do
        policy = described_class.new(admin, user)
        expect(policy.public_send(action)).to be true
      end
    end
  end

  describe "Scope" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    it "returns all users for admin" do
      scope = described_class::Scope.new(admin, User).resolve
      expect(scope).to include(user1, user2)
    end

    it "returns empty scope for non-admin users" do
      scope = described_class::Scope.new(seller, User).resolve
      expect(scope).to include(user1, user2)
    end
  end
end
