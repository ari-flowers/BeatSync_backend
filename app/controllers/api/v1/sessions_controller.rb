# app/controllers/api/v1/sessions_controller.rb
module Api
  module V1
    class SessionsController < Devise::SessionsController
      include RackSessionsFix
      skip_before_action :verify_authenticity_token, raise: false
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        render json: {
          status: { code: 200, message: 'Logged in successfully.' },
          data: { id: resource.id, email: resource.email }
        }, status: :ok
      end

      def respond_to_on_destroy
        head :no_content
      end
    end
  end
end