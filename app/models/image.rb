class Image < ActiveRecord::Base
    attr_accessor :img_height, :img_width, :color_list, :color_hash

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
        pixels = []
        i = 0
        while i < raw_pixels.length
            pixels << [raw_pixels[i], raw_pixels[i+1], raw_pixels[i+2]]
            i += 3
        end
        return pixels
    end

    def sort_pixels_by_color
        #yellow, green, teal, blue, purple, pink, white, gray, black and brown
        colors = {"yellow" => [65535, 65535, 0],
        "green" => [0, 65535,0],
        "teal" => [13770, 29835, 34680],
        "blue" => [0, 0, 65535],
        "purple" => [32768, 0, 65535],
        "pink" =>[65535, 0, 65535 ],
        "white" => [65535, 65536, 65535],
        "gray" => [49152, 49152, 49152],
        "black" => [0,0,0],
        "brown" => [35445, 17595, 4845]}

        pixel_colors = []
        self.get_pixels.each do |pixel|
            #count of each color
            #array with colors of each pixel
            min_distance = -1
            pixel_color = ""
            colors.each do |name, value|
                distance = (((pixel[0] - value[0])**2) + ((pixel[1] - value[1])**2) + ((pixel[2] - value[2])**2))**0.5
                if distance < min_distance || min_distance == -1
                    min_distance = distance
                    pixel_color = name
                end
            end
            pixel_colors << pixel_color
        end
        @color_list = pixel_colors
        return pixel_colors
    end

    def get_color_counts
        color_counts = Hash.new(0)
        pixel_colors = self.color_list
        pixel_colors.each do |color|
            color_counts[color] += 1
        end
        @color_hash = color_counts
        color_counts
    end


     def assemble_pictures(pictures)

        #Assuming all the images are in the current directory and named 
        #from 1.jpg to n.jpg and row * col = n.
        #(y + (x-1)*col).to_s + ".jpg"
        # pictures = search.picture_array.to_enum

        row = self.rows
        col = self.cols
        ilg = ImageList.new
        1.upto(col) {|x| il = ImageList.new
            1.upto(row) {|y| il.push(Image.read(pictures.next).first)}
            ilg.push(il.append(false))}
        ilg.append(true).write("out.jpg")
    end


end
