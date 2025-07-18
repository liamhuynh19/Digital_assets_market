# require 'rails_helper'

# RSpec.describe Admin::ProductsController, type: :controller do
#   include Devise::Test::ControllerHelpers

#   let(:admin) { create(:user, role: 'admin') }
#   let(:seller) { create(:user, role: 'seller') }
#   let(:buyer) { create(:user, role: 'buyer') }
#   let(:product) { create(:product, user: seller) }
#   let(:valid_attributes) {
#     {
#       name: 'Test Product',
#       description: 'Test Description',
#       price: 99.99,
#       category_id: create(:category).id,
#       file_url: 'http://example.com/file.pdf'
#     }
#   }

#   describe 'GET #index' do
#     context 'when user is admin' do
#       before { sign_in admin, scope: :user }

#       it 'assigns all products as @products' do
#         get :index, params: {}
#         expect(assigns(:products)).to include(product)
#         expect(response).to be_successful
#       end
#     end
#   end

#   describe 'GET #show' do
#     context 'when user is admin' do
#       before { sign_in admin, scope: :user }

#       it 'assigns the requested product as @product' do
#         get :show, params: { id: product.id }
#         expect(assigns(:product)).to eq(product)
#         expect(response).to be_successful
#       end
#     end
#   end

#   describe 'GET #new' do
#     context 'when user is admin' do
#       before { sign_in admin, scope: :user }

#       it 'assigns a new product as @product' do
#         get :new
#         expect(assigns(:product)).to be_a_new(Product)
#         expect(response).to be_successful
#       end
#     end
#   end

#   describe 'POST #create' do
#     context 'when user is admin' do
#       before { sign_in admin, scope: :user }

#       context 'with valid params' do
#         it 'creates a new Product' do
#           expect {
#             post :create, params: { product: valid_attributes }
#           }.to change(Product, :count).by(1)
#         end

#         it 'assigns the current user as the product owner' do
#           post :create, params: { product: valid_attributes }
#           expect(Product.last.user).to eq(admin)
#         end

#         it 'redirects to the created product' do
#           post :create, params: { product: valid_attributes }
#           expect(response).to redirect_to(admin_product_path(Product.last))
#         end
#       end

#       context 'with invalid params' do
#         it 'returns to new template' do
#           post :create, params: { product: { name: '' } }
#           expect(response).to render_template(:new)
#         end
#       end
#     end
#   end

#   describe 'GET #edit' do
#     context 'when user is admin' do
#       before { sign_in admin, scope: :user }

#       it 'assigns the requested product as @product' do
#         get :edit, params: { id: product.id }
#         expect(assigns(:product)).to eq(product)
#         expect(response).to be_successful
#       end
#     end
#   end

#   describe 'PUT #update' do
#     context 'when user is admin' do
#       before { sign_in admin, scope: :user }

#       context 'with valid params' do
#         let(:new_attributes) { { name: 'Updated Name' } }

#         it 'updates the requested product' do
#           put :update, params: { id: product.id, product: new_attributes }
#           product.reload
#           expect(product.name).to eq('Updated Name')
#         end

#         it 'redirects to the product' do
#           put :update, params: { id: product.id, product: new_attributes }
#           expect(response).to redirect_to(admin_product_path(product))
#         end
#       end

#       context 'with invalid params' do
#         it 'returns to edit template' do
#           put :update, params: { id: product.id, product: { name: '' } }
#           expect(response).to render_template(:edit)
#         end
#       end
#     end
#   end

#   describe 'DELETE #destroy' do
#     context 'when user is admin' do
#       before { sign_in admin, scope: :user }

#       it 'destroys the requested product' do
#         product_to_delete = create(:product)
#         expect {
#           delete :destroy, params: { id: product_to_delete.id }
#         }.to change(Product, :count).by(-1)
#       end

#       it 'redirects to the products list' do
#         delete :destroy, params: { id: product.id }
#         expect(response).to redirect_to(admin_products_path)
#       end
#     end
#   end
# end
