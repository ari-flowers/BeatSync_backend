class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::Helpers
  respond_to :json

  # Don't require authentication globally — opt-in per controller
  # This avoids issues on unauthenticated routes like sign_in and sign_up
  # Controllers that need auth can still call `before_action :authenticate_user!`

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # For sign_in
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])

    # Also keep this here in case you customize sign_up or account_update later
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :password, :password_confirmation, :current_password])
  end

  private

  def unauthorized!
    render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
  end
end