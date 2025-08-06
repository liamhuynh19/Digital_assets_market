class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: [ :create ]
  respond_to :json

  def create
    user = User.find_by(email: sign_in_params[:email])
    if user && user.valid_password?(sign_in_params[:password])
      sign_in user
      token = generate_jwt_token(user)

      render json: {
        data: {
          token: token
        }
      }
    else
      render json: {
        data: {
          error: "Invalid email or password",
          status: :unauthorized
          }
        }
    end
  end


  private
  def sign_in_params
    params.permit(:email, :password)
  end

  def generate_jwt_token(user)
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, "digital_asset_secret_key")
  end
end
