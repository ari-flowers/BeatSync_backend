class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_authenticity_token, raise: false
  skip_before_action :authenticate_user!, raise: false

  private

  def respond_with(resource, _opts = {})
    if resource.present?
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: {
          id: resource.id,
          email: resource.email,
          created_at: resource.created_at,
          updated_at: resource.updated_at
        }
      }, status: :ok
    else
      render json: {
        status: { code: 401, message: 'Invalid credentials.' }
      }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    render json: { status: 200, message: "Logged out successfully." }, status: :ok
  end
end