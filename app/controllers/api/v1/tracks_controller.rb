module Api
  module V1
    class TracksController < ApplicationController
      before_action :set_track, only: [:show, :update, :destroy]

      # GET /api/v1/tracks/:id
      def show
        render json: @track
      end

      # PATCH/PUT /api/v1/tracks/:id
      def update
        if @track.update(track_params)
          render json: @track
        else
          render json: @track.errors, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/tracks/:id
      def destroy
        @track.destroy
        head :no_content
      end

      private

      def set_track
        @track = Track.find(params[:id])
      end

      def track_params
        params.require(:track).permit(:name, :spotify_id, :artist_name, :duration_ms, :image_url)
      end
    end
  end
end