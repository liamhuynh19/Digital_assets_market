module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user_from_token!
  end

  private

  def authenticate_user_from_token!
    token = extract_token_from_header
    return render json: { error: "No token provided" }, status: :unauthorized unless token

    begin
      decoded_token = JWT.decode(token, "digital_asset_secret_key", true, { algorithm: "HS256" })
      user_id = decoded_token.first["user_id"]
      @current_user = User.find_by(id: user_id)

      unless @current_user
        render json: { error: "Invalid token" }, status: :unauthorized
      end
    rescue JWT::DecodeError
      render json: { error: "Invalid token" }, status: :unauthorized
    rescue JWT::ExpiredSignature
      render json: { error: "Token has expired" }, status: :unauthorized
    end
  end

  def extract_token_from_header
    request.headers["Authorization"]&.split(" ")&.last
  end
end
