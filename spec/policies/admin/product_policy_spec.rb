require 'rails_helper'

RSpec.describe Admin::ProductPolicy do
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
  let(:other_seller_product) { create(:product, name: "Other seller's product", user: other_seller) }

  describe '#index?' do
    it "denies access to buyers" do
      policy = described_class.new(buyer, Product)
      expect(policy.index?).to be false
    end

    it "allows access to admin" do
      policy = described_class.new(admin, Product)
      expect(policy.index?).to be true
    end

    it "allows access to sellers" do
      policy = described_class.new(seller, Product)
      expect(policy.index?).to be true
    end
  end

  describe '#show?' do
    it "denies access to buyers" do
      policy = described_class.new(buyer, product)
      expect(policy.show?).to be false
    end

    it "allows admin to view any product" do
      policy = described_class.new(admin, product)
      expect(policy.show?).to be true

      policy = described_class.new(admin, other_seller_product)
      expect(policy.show?).to be true
    end

    it "allows seller to view only their products" do
      policy = described_class.new(seller, product)
      expect(policy.show?).to be true

      policy = described_class.new(seller, other_seller_product)
      expect(policy.show?).to be false
    end
  end

  describe '#create?' do
    it "denies access to buyers" do
      policy = described_class.new(buyer, Product)
      expect(policy.create?).to be false
    end

    it "allows admin to create products" do
      policy = described_class.new(admin, Product)
      expect(policy.create?).to be true
    end

    it "allows sellers to create products" do
      policy = described_class.new(seller, Product)
      expect(policy.create?).to be true
    end
  end

  describe "Scope" do
    context "when user is admin" do
      it "shows all products" do
        scope = described_class::Scope.new(admin, Product).resolve
        expect(scope).to include(product, other_seller_product)
      end
    end

    context "when user is seller" do
      it "shows only their products" do
        scope = described_class::Scope.new(seller, Product).resolve
        expect(scope).to include(product)
        expect(scope).not_to include(other_seller_product)
      end
    end

    context "when user is buyer" do
      it "shows no products" do
        scope = described_class::Scope.new(buyer, Product).resolve
        expect(scope).to be_empty
      end
    end
  end
end
