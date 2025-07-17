# require 'rails_helper'

# RSpec.describe ProductsController, type: :controller do
#   include Devise::Test::IntegrationHelpers
#   let(:user) { create(:user) }

#   describe "GET #index" do
#     context "when user is logged in" do
#       before do
#     sign_in user
#   end

#       it "returns successful response" do
#         sign_in user
#         get :index
#         expect(response).to be_successful
#       end

#       it "paginates results" do
#         create_list(:product, 20, user: user)
#         get :index
#         expect(assigns(:products).size).to eq(8)
#       end
#     end
#   end
# end
