require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:valid_attributes) do
    {
      name: "Digital Asset",
      description: "A great digital product",
      price: 99.99,
      user: user,
      category: category
    }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:category) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe 'creation' do
    it 'creates a valid product' do
      product = Product.new(valid_attributes)
      expect(product).to be_valid
    end

    it 'is invalid without a name' do
      product = Product.new(valid_attributes.merge(name: nil))
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a description' do
      product = Product.new(valid_attributes.merge(description: nil))
      expect(product).not_to be_valid
      expect(product.errors[:description]).to include("can't be blank")
    end

    it 'is invalid with a negative price' do
      product = Product.new(valid_attributes.merge(price: -1))
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include("must be greater than or equal to 0")
    end
  end
end
