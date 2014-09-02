class Image < ActiveRecord::Base
    attr_accessor :img_height, :img_width, :color_list, :color_hash, :pixels, :ordered_tiles

    require 'RMagick'
    include Magick
    # extend CarrierWave::Mount
    mount_uploader :avatar, AvatarUploader

    validates_integrity_of  :avatar

    def get_pixel_list(length, width)
        @img = ImageList.new(self.avatar.current_path())
        @img.resize_to_fit!(length, width)
        @img = @img.contrast(sharpen=true)
        #break image up into small pieces
        pixels = @img.export_pixels()
    end

    def rows  
        @img.rows
    end

    def cols
        @img.columns
    end


    def get_pixels(length, width)
        raw_pixels = self.get_pixel_list(length, width)
        @pixels = []
        i = 0
        while i < raw_pixels.length
            pixels << [raw_pixels[i], raw_pixels[i+1], raw_pixels[i+2]]
            i += 3
        end
        return @pixels
    end


    def color_distance(color1, color2)
        distance = (((color1[0] - color2[0])**2) + ((color1[1] - color2[1])**2) + ((color1[2] - color2[2])**2))**0.5
    end

    def find_matching_tile(pixel, tile_colors)
        distances = tile_colors.collect do |tile|
            self.color_distance(pixel, tile)
        end
        distances.index(distances.min)
    end

    def match_all_pixels(tile_colors)
        @color_list = self.pixels.collect do |pixel|
            find_matching_tile(pixel, tile_colors)
        end
    end

    def order_tiles(photo_tiles)
        l = Magick::ImageList.new
        color_list.each do |i|
            l << photo_tiles[i].copy
        end
        @ordered_tiles = l
    end

    def make_mosaic(photo_length, photo_width, tile_length, tile_width)
        puts "getting pixels"
        time = Time.now
        self.get_pixels(photo_length, photo_width)
        s = Search.new(self.search)
        puts "going to the seach class"
        s.complete_search(tile_length, tile_width)
        puts "matching pixels with image tiles"

        self.match_all_pixels(s.photo_tile_colors)
        puts "putting tiles in order"
        self.order_tiles(s.resized_photo_tiles)
        m = Mosaic.new
        puts "ordering photos for mosaic"
        photos = m.order_photos(self.ordered_tiles, self.rows, self.cols, tile_length, tile_width)
        puts "making mosaic"
        m.create_mosaic(photos)
        puts Time.now - time
    end

    def quick_make_mosaic(photo_length, photo_width, tile_length, tile_width)
        self.get_pixels(photo_length, photo_width)
        s = Search.last
        s.resize_pictures(tile_length, tile_width)
        s.average_color_list

        photos = m.order_photos(self.ordered_tiles, self.rows, self.cols)

        m.create_mosaic(photos)
    end

end
