module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      skip_before_action :authenticate_user!, raise: false

      respond_to :json

      private

      def respond_with(resource, _opts = {})
        if resource && resource.persisted?
          render json: {
            status: { code: 200, message: 'Signed up successfully.' },
            data: {
              id: resource.id,
              email: resource.email,
              created_at: resource.created_at,
              updated_at: resource.updated_at
            }
          }, status: :ok
        else
          render json: {
            status: { code: 422, message: 'Registration failed.', errors: resource.errors.full_messages }
          }, status: :unprocessable_entity
        end
      end
    end
  end
end