# app/controllers/api/v1/sessions_controller.rb
module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        if resource.present?
          render json: {
            status: { code: 200, message: 'Signed in successfully.' },
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
        if current_user
          render json: {
            status: 200,
            message: 'Signed out successfully.'
          }, status: :ok
        else
          render json: {
            status: 401,
            message: 'User has no active session.'
          }, status: :unauthorized
        end
      end
    end
  end
end