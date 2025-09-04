
require 'rails_helper'
RSpec.describe Admin::CategoryPolicy do
  let(:category) { create(:category) }
  context "for a seller" do
    let(:seller) do
      user = create(:user)
      user.add_role('seller')
      user.set_current_role('seller')
      user
    end

    let(:policy) { described_class.new(seller, category) }
    # permissions :index?, :show? do
    #   it { expect(policy).to permit_action }
    # end
    describe "index? and show?" do
      it "permits access" do
        expect(policy.index?).to be true
        expect(policy.show?).to be true
      end
    end

    describe "new?, create?, edit?, update?, destroy?" do
      it "denies access" do
        expect(policy.new?).to be false
        expect(policy.create?).to be false
        expect(policy.edit?).to be false
        expect(policy.update?).to be false
        expect(policy.destroy?).to be false
      end
    end
  end

  context "for an admin" do
    let(:admin) do
      user = create(:user)
      user.add_role("admin")
      user.set_current_role("admin")
      user
    end
    let(:policy) { described_class.new(admin, category) }
    describe "all actions" do
      it "permits access" do
        expect(policy.index?).to be true
        expect(policy.show?).to be true
        expect(policy.create?).to be true
        expect(policy.new?).to be true
        expect(policy.edit?).to be true
        expect(policy.update?).to be true
        expect(policy.destroy?).to be true
      end
    end
  end
end
