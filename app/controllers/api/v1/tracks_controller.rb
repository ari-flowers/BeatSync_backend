module Api
  module V1
    class TracksController < ApplicationController
      before_action :authenticate_user!
      before_action :set_playlist
      before_action :set_track, only: [:show, :update, :destroy]

      # GET /api/v1/playlists/:playlist_id/tracks
      def index
        @tracks = @playlist.tracks
        render json: @tracks
      end

      # GET /api/v1/playlists/:playlist_id/tracks/:id
      def show
        render json: @track
      end

      # POST /api/v1/playlists/:playlist_id/tracks
      def create
        @track = @playlist.tracks.new(track_params)
        if @track.save
          render json: @track, status: :created
        else
          render json: @track.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/playlists/:playlist_id/tracks/:id
      def update
        if @track.update(track_params)
          render json: @track
        else
          render json: @track.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/playlists/:playlist_id/tracks/:id
      def destroy
        @track.destroy
        head :no_content
      end

      private

      def set_playlist
        @playlist = current_user.playlists.find(params[:playlist_id])
      end

      def set_track
        @track = @playlist.tracks.find(params[:id])
      end

      def track_params
        params.require(:track).permit(:title, :artist, :album, :image_url, :spotify_id)
      end
    end
  end
end