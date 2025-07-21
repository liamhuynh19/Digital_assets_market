require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  include Devise::Test::ControllerHelpers
  Rails.application.reload_routes!
  let(:user) { create(:user) } # Assuming you have a User factory

  describe "GET #index" do
    context "when user is logged in" do
      before do
        sign_in user, scope: :user
      end

      it "returns a successful response" do
        get :index
        expect(response).to be_successful
      end

      # it "paginates results" do
      #   create_list(:product, 9, user: user)
      #   get :index
      #   expect(assigns(:products).size).to eq(8)
      # end
    end

    context "when user is not logged in" do
      it "redirects to sign in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET #show' do
    # Create a dummy product for testing
    let(:product) { create(:product, user: user) }

    context 'when user is authenticated' do
      before do
        sign_in user, scope: :user
      end

      it 'assigns @product' do
        get :show, params: { id: product.id }
        expect(assigns(:product)).to eq(product)
      end

      context 'when product does not exist' do
        it 'raises a RecordNotFound error' do
          expect {
            get :show, params: { id: 99999 }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to the sign in page' do
        # No sign_in user here
        get :show, params: { id: product.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
