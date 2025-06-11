module Api
  module V1
    class TracksController < BaseController
      before_action :set_playlist
      before_action :set_track, only: [:show, :update, :destroy]

      def index
        render json: @playlist.tracks
      end

      def show
        render json: @track
      end

      def create
        track = @playlist.tracks.new(track_params)
        if track.save
          render json: track, status: :created
        else
          render json: track.errors, status: :unprocessable_entity
        end
      end

      def update
        if @track.update(track_params)
          render json: @track
        else
          render json: @track.errors, status: :unprocessable_entity
        end
      end

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