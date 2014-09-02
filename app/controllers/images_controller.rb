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
        @image.make_mosaic(150,150,10,10)
        redirect_to @image
    end

    def show
        @image = Image.find(params[:id])
        @search = Search.new(@image.search)
    end
end
