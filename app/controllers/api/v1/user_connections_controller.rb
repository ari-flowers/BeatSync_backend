module Api
  module V1
    class UserConnectionsController < BaseController
      def index
        render json: current_user.user_connections
      end

      def show
        connection = current_user.user_connections.find(params[:id])
        render json: connection
      end

      def create
        connection = current_user.user_connections.new(user_connection_params)
        if connection.save
          render json: connection, status: :created
        else
          render json: connection.errors, status: :unprocessable_entity
        end
      end

      def update
        connection = current_user.user_connections.find(params[:id])
        if connection.update(user_connection_params)
          render json: connection
        else
          render json: connection.errors, status: :unprocessable_entity
        end
      end

      def destroy
        connection = current_user.user_connections.find(params[:id])
        connection.destroy
        head :no_content
      end

      private

      def user_connection_params
        params.require(:user_connection).permit(:provider, :access_token, :refresh_token, :token_expires_at)
      end
    end
  end
end