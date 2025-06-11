class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json

  # Authenticate user by default on all requests
  before_action :authenticate_user!

  private

  # Customize unauthorized response
  def unauthorized!
    render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
  end
end