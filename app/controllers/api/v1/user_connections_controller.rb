module Api
  module V1
    class UserConnectionsController < ApplicationController
      before_action :set_user_connection, only: [:show, :update, :destroy]

      # GET /api/v1/user_connections
      def index
        @user_connections = UserConnection.all
        render json: @user_connections
      end

      # GET /api/v1/user_connections/:id
      def show
        render json: @user_connection
      end

      # POST /api/v1/user_connections
      def create
        @user_connection = UserConnection.new(user_connection_params)
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
        @user_connection = UserConnection.find(params[:id])
      end

      def user_connection_params
        params.require(:user_connection).permit(:provider, :uid, :access_token, :refresh_token, :expires_at)
      end
    end
  end
end