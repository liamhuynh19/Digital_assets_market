require "rails_helper"
RSpec.describe Admin::OrderPolicy do
  let(:admin) do
    user = create(:user)
    user.add_role('admin')
    user.set_current_role('admin')
    user
  end

  let(:seller) do
    user = create(:user)
    user.add_role("seller")
    user.set_current_role("seller")
    user
  end

  let(:other_seller) do
    user = create(:user)
    user.add_role("seller")
    user.set_current_role("seller")
    user
  end

  let(:buyer) do
    user = create(:user)
    user.add_role("buyer")
    user.set_current_role("buyer")
    user
  end

  let(:product_1) { create(:product, name: "Seller's product 1", user: seller) }
  let(:product_2) { create(:product, name: "Other seller's product 2", user:  other_seller) }
  let(:order_1) do
    order = create(:order, user: buyer)
    create(:order_item, order: order, product: product_1)
    order
  end

  let(:order_2) do
    order = create(:order, user: buyer)
    create(:order_item, order: order, product: product_2)
    order
  end

  let(:order_3) do
    order = create(:order, user: buyer)
    create(:order_item, order: order, product: product_1)
    create(:order_item, order: order, product: product_2)
    order
  end

  describe "scope" do
    before do
      order_1
      order_2
      order_3
    end

    context "for admin" do
      subject { described_class::Scope.new(admin, Order).resolve }
      it "returns all orders" do
        expect(subject.count).to eq(3)
      end

      it "includes associations" do
        expect(subject.first.association(:user)).to be_loaded
        expect(subject.first.association(:order_items)).to be_loaded
      end
    end

    context "for seller" do
      subject { described_class::Scope.new(seller, Order).resolve }

      it "returns orders containing seller's products" do
        expect(subject.count).to eq(2)
        expect(subject).to include(order_1)
        expect(subject).to include(order_3)
        expect(subject).not_to include(order_2)
      end
    end
  end

  describe "#index?" do
    it "allows access to admin" do
      policy = described_class.new(admin, Order)
      expect(policy.index?).to be true
    end

    it "allows access to seller" do
      policy = described_class.new(seller, Order)
      expect(policy.index?).to be true
    end

    it "denies access to buyer" do
      policy = described_class.new(buyer, Order)
      expect(policy.index?).to be false
    end
  end

  describe "#show?" do
    it "allows admin to view any order" do
      policy = described_class.new(admin, order_1)
      expect(policy.show?).to be true

      policy_2 = described_class.new(admin, order_2)
      expect(policy_2.show?).to be true
    end

    it "allows seller to view orders containing their products" do
      policy = described_class.new(seller, order_1)
      expect(policy.show?).to be true
      policy_2 = described_class.new(seller, order_3)
      expect(policy_2.show?).to be true
      policy_3 = described_class.new(seller, order_2)
      expect(policy_3.show?).to be false
    end

    it "denies buyer access to any order in admin panel" do
      order = [ order_1, order_2, order_3 ].sample
      policy = described_class.new(buyer, order)
      expect(policy.show?).to be false
    end
  end

  %i[create? new? update? edit? destroy?].each do |action |
    describe "#action" do
      it "allows access to admin" do
        policy = described_class.new(admin, Order)
        expect(policy.public_send(action)).to be true
      end

      it "denies access to seller" do
        policy = described_class.new(seller, Order)
        expect(policy.public_send(action)).to be false
      end

      it "denies access to buyer" do
        policy = Admin::OrderPolicy.new(buyer, Order)
        expect(policy.public_send(action)).to be false
      end
    end
  end
end
