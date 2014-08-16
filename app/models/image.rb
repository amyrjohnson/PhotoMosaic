class Image < ActiveRecord::Base
    attr_accessor :img_height, :img_width, :color_list, :color_hash, :pixels, :ordered_tiles

    require 'RMagick'
    include Magick
    # extend CarrierWave::Mount
    mount_uploader :avatar, AvatarUploader

    validates_integrity_of  :avatar

    def get_pixel_list
        @img = ImageList.new(self.avatar.current_path())
        @img.resize_to_fit!(32,32)
        #break image up into small pieces
        pixels = @img.export_pixels()
    end

    def rows  
        @img.rows
    end

    def cols
        @img.columns
    end


    def get_pixels
        raw_pixels = self.get_pixel_list
        @pixels = []
        i = 0
        while i < raw_pixels.length
            pixels << [raw_pixels[i], raw_pixels[i+1], raw_pixels[i+2]]
            i += 3
        end
        return @pixels
    end

    # def sort_pixels_by_color
    #     #yellow, green, teal, blue, purple, pink, white, gray, black and brown
    #     colors = {"yellow" => [65535, 65535, 0],
    #     "green" => [0, 65535,0],
    #     "teal" => [13770, 29835, 34680],
    #     "blue" => [0, 0, 65535],
    #     "purple" => [32768, 0, 65535],
    #     "pink" =>[65535, 0, 65535 ],
    #     "white" => [65535, 65536, 65535],
    #     "gray" => [49152, 49152, 49152],
    #     "black" => [0,0,0],
    #     "brown" => [35445, 17595, 4845]}

    #     pixel_colors = []
    #     self.get_pixels.each do |pixel|
    #         #count of each color
    #         #array with colors of each pixel
    #         min_distance = -1
    #         pixel_color = ""
    #         colors.each do |name, value|
    #             distance = (((pixel[0] - value[0])**2) + ((pixel[1] - value[1])**2) + ((pixel[2] - value[2])**2))**0.5
    #             if distance < min_distance || min_distance == -1
    #                 min_distance = distance
    #                 pixel_color = name
    #             end
    #         end
    #         pixel_colors << pixel_color
    #     end
    #     @color_list = pixel_colors
    #     return pixel_colors
    # end

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

    def make_mosaic
        puts "getting pixels"
        self.get_pixels
        s = Search.new(self.search)
        puts "going to the seach class"
        s.complete_search
        puts "matching pixels with image tiles"
        self.match_all_pixels(s.photo_tile_colors)
        puts "putting tiles in order"
        self.order_tiles(s.resized_photo_tiles)
        m = Mosaic.new
        puts "ordering photos for mosaic"
        photos = m.order_photos(self.ordered_tiles, self.rows, self.cols)
        puts "making mosaic"
        m.create_mosaic(photos)
    end

    # def get_color_counts
    #     color_counts = Hash.new(0)
    #     pixel_colors = self.color_list
    #     pixel_colors.each do |color|
    #         color_counts[color] += 1
    #     end
    #     @color_hash = color_counts
    #     color_counts
    # end

    # def setup
    #     self.sort_pixels_by_color
    #     self.get_color_counts
    # end


end
