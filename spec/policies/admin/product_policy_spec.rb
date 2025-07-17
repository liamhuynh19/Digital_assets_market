require 'rails_helper'

RSpec.describe Admin::ProductPolicy do
  let(:admin) { create(:user, role: 'admin') }
  let(:seller) { create(:user, name: "Seller", role: 'seller') }
  let(:other_seller) { create(:user, name: "Other Seller", role: 'seller') }
  let(:buyer) { create(:user, role: 'buyer') }
  let(:product) { create(:product, user: seller) }
  let(:other_product) { create(:product, name: "Other Product", user: other_seller) }

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

      policy = described_class.new(admin, other_product)
      expect(policy.show?).to be true
    end

    it "allows seller to view only their products" do
      policy = described_class.new(seller, product)
      expect(policy.show?).to be true

      policy = described_class.new(seller, other_product)
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
    let!(:seller_product) { create(:product, user: seller) }
    let!(:other_seller_product) { create(:product, user: other_seller) }

    context "when user is admin" do
      it "shows all products" do
        scope = described_class::Scope.new(admin, Product).resolve
        expect(scope).to include(seller_product, other_seller_product)
      end
    end

    context "when user is seller" do
      it "shows only their products" do
        scope = described_class::Scope.new(seller, Product).resolve
        expect(scope).to include(seller_product)
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
