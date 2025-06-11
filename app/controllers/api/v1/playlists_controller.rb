module Api
  module V1
    class PlaylistsController < BaseController
      before_action :set_playlist, only: [:show, :update, :destroy]

      # GET /api/v1/playlists
      def index
        @playlists = current_user.playlists
        render json: @playlists
      end

      # GET /api/v1/playlists/:id
      def show
        render json: @playlist
      end

      # POST /api/v1/playlists
      def create
        @playlist = current_user.playlists.new(playlist_params)
        if @playlist.save
          render json: @playlist, status: :created
        else
          render json: @playlist.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/playlists/:id
      def update
        if @playlist.update(playlist_params)
          render json: @playlist
        else
          render json: @playlist.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/playlists/:id
      def destroy
        @playlist.destroy
        head :no_content
      end

      private

      def set_playlist
        @playlist = current_user.playlists.find(params[:id])
      end

      def playlist_params
        params.require(:playlist).permit(:name, :spotify_id, :description, :image_url, :is_public)
      end
    end
  end
end