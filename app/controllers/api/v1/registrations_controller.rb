# app/controllers/api/v1/registrations_controller.rb
module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      include RackSessionsFix
      skip_before_action :verify_authenticity_token, raise: false
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: { status: { code: 200, message: 'Signed up successfully.' },
                         data: { id: resource.id, email: resource.email } },
                 status: :ok
        else
          render json: { status: { code: 422, message: 'Registration failed.', errors: resource.errors.full_messages } },
                 status: :unprocessable_entity
        end
      end
    end
  end
end