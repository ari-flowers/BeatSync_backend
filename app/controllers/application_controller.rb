class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json

  # Leave authenticate_user! opt-in
  private

  def unauthorized!
    render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
  end
end