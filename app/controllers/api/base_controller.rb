class Api::BaseController < ApplicationController
  include JwtAuthenticatable
  skip_before_action :verify_authenticity_token
end
