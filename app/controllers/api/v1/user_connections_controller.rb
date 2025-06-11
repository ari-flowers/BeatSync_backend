module Api
  module V1
    class UserConnectionsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_user_connection, only: [:show, :update, :destroy]

      # GET /api/v1/user_connections
      def index
        @user_connections = current_user.user_connections
        render json: @user_connections
      end

      # GET /api/v1/user_connections/:id
      def show
        render json: @user_connection
      end

      # POST /api/v1/user_connections
      def create
        @user_connection = current_user.user_connections.new(user_connection_params)
        if @user_connection.save
          render json: @user_connection, status: :created
        else
          render json: @user_connection.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/user_connections/:id
      def update
        if @user_connection.update(user_connection_params)
          render json: @user_connection
        else
          render json: @user_connection.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/user_connections/:id
      def destroy
        @user_connection.destroy
        head :no_content
      end

      private

      def set_user_connection
        @user_connection = current_user.user_connections.find(params[:id])
      end

      def user_connection_params
        params.require(:user_connection).permit(:provider, :access_token, :refresh_token, :token_expires_at)
      end
    end
  end
end