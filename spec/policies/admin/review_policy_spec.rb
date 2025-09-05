require "rails_helper"

RSpec.describe Admin::ReviewPolicy do
  let(:admin) do
    user = create(:user)
    user.add_role('admin')
    user.set_current_role('admin')
    user
  end

  let(:seller) do
    user = create(:user, role: 'seller')
    user.add_role('seller')
    user.set_current_role('seller')
    user
  end

  let(:other_seller) do
    user = create(:user, role: 'seller')
    user.add_role('seller')
    user.set_current_role('seller')
    user
  end

  let(:buyer) do
    user = create(:user, role: 'buyer')
    user.add_role('buyer')
    user.set_current_role('buyer')
    user
  end

  let(:product) { create(:product, name: "Seller's product", user: seller) }
  let(:other_seller_product) { create(:product, name: "Other seller's product 1", user: other_seller) }
  let(:order) do
    order = create(:order, user: buyer, status: "paid")
    create(:order_item, order: order, product: product)
    create(:order_item, order: order, product: other_seller_product)
    order
  end

  let(:review) do
    order
    create(:review, product: product, user: buyer)
  end
  let(:other_review) do
    order
    create(:review, product: other_seller_product, user: buyer)
  end

  describe "Scope" do
    before do
      review
      other_review
    end

    context "for admin" do
      subject { described_class::Scope.new(admin, Review).resolve }

      it "returns all reviews" do
        expect(subject).to include(review, other_review)
      end
    end

    context "for seller" do
      subject { described_class::Scope.new(seller, Review).resolve }

      it "returns reviews for their products" do
        expect(subject).to include(review)
        expect(subject).not_to include(other_review)
      end
    end

    context "for buyer" do
      subject { described_class::Scope.new(buyer, Review).resolve }

      it "returns no reviews" do
        expect(subject).to be_empty
      end
    end
  end

  describe '#index?' do
    it "denies access to buyers" do
      policy = described_class.new(buyer, Review)
      expect(policy.index?).to be false
    end

    it "allows access to admin" do
      policy = described_class.new(admin, Review)
      expect(policy.index?).to be true
    end

    it "allows access to sellers " do
      policy = described_class.new(seller, Review)
      expect(policy.index?).to be true
    end
  end

  describe '#show?' do
    it "denies access to buyers" do
      policy = described_class.new(buyer, review)
      expect(policy.show?).to be false
    end

    it "allows admin to view any review" do
      policy = described_class.new(admin, review)
      expect(policy.show?).to be true

      policy = described_class.new(admin, other_review)
      expect(policy.show?).to be true
    end

    it "allows seller to view reviews for their products" do
      policy = described_class.new(seller, review)
      expect(policy.show?).to be true
    end

    it "denies seller access to reviews for other products" do
      policy = described_class.new(seller, other_review)
      expect(policy.show?).to be false
    end
  end

  describe "#destroy?" do
    it "denies access to buyers" do
      policy = described_class.new(buyer, review)
      expect(policy.destroy?).to be false
    end

    it "allows admin to destroy any review" do
      policy = described_class.new(admin, review)
      expect(policy.destroy?).to be true

      policy = described_class.new(admin, other_review)
      expect(policy.destroy?).to be true
    end

    it "denies seller to destroy reviews" do
      policy = described_class.new(seller, review)
      expect(policy.destroy?).to be false

      policy = described_class.new(seller, other_review)
      expect(policy.destroy?).to be false
    end
  end
end
