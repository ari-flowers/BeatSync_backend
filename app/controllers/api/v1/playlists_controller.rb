module Api
  module V1
    class PlaylistsController < ApplicationController
      before_action :set_playlist, only: [:show, :update, :destroy]

      # GET /api/v1/playlists
      def index
        @playlists = Playlist.all
        render json: @playlists
      end

      # GET /api/v1/playlists/:id
      def show
        render json: @playlist
      end

      # POST /api/v1/playlists
      def create
        @playlist = Playlist.new(playlist_params)
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
        @playlist = Playlist.find(params[:id])
      end

      def playlist_params
        params.require(:playlist).permit(:name, :spotify_id, :description, :image_url, :is_public)
      end
    end
  end
end