require 'rails_helper'
RSpec.describe User, type: :model do
  let(:valid_user_attributes) do
    {
      email: "user@example.com",
      password: "password123",
      password_confirmation: "password123",
      name: "Test User",
      role: "buyer"
    }
  end
  describe "validations" do
    it 'is valid with valid attributes' do
      user = User.new(valid_user_attributes)
      expect(user).to be_valid
    end

    it 'requires an email' do
      user = User.new(valid_user_attributes.merge(email: nil))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end


    it 'requires a unique email' do
      User.create!(valid_user_attributes)
      user = User.new(valid_user_attributes)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end
  end

  describe "role" do
    it 'set dafault role to user as buyer if not specified' do
      user = User.new(valid_user_attributes.except(:role))
      expect(user).to be_valid
      expect(user.role).to eq("buyer")
    end
  end
end
