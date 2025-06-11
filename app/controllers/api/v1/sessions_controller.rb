module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        render json: {
          status: { code: 200, message: 'Signed in successfully.' },
          data: resource
        }, status: :ok
      end

      def respond_to_on_destroy
        if current_user
          render json: {
            status: 200,
            message: "Signed out successfully."
          }, status: :ok
        else
          render json: {
            status: 401,
            message: "Couldn't find an active session."
          }, status: :unauthorized
        end
      end
    end
  end
end