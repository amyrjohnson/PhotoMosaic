class ImagesController < ApplicationController

    def index
        @image = Image.new
    end

    def create
        @image = Image.new
        @image.avatar = params[:image][:avatar]
        @image.search = params[:image][:search]
        @image.save
        # uploader = AvatarUploader.new
        # uploader.store!(params[:picture])
        redirect_to @image
    end

    def show
        @image = Image.find(params[:id])
        @search = Search.new(@image.search)
    end
end
