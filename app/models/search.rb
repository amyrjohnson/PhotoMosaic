require 'open-uri'
require 'json'
require 'timeout'

class Search

    require 'RMagick'
    include Magick

  # attr_accessor :image_hash, :image_list, :resized_pictures, :object_hash, :conversion_hash, 
  attr_accessor :photo_tiles, :resized_photo_tiles, :photo_tile_colors, :search_term

   # def get_pictures(color_hash, search_term)
   #      color_image_hash = {}
   #      api_key = "AIzaSyBqHvq5UeKEtmOVSGZ0vWrjKK1YGRS_4k8"

   #      color_hash.each do |color, count|
   #          source = "https://www.googleapis.com/customsearch/v1?q=#{search_term}&cx=012238431153746656688%3Ai-xqvgd0-hq&imgDominantColor=#{color}&searchType=image&key=#{api_key}"
   #          data = JSON.load(open(source))

   #          (0..count).each do |i|
   #              if data["items"][i]
   #                  if color_image_hash[color]
   #                      color_image_hash[color] << data["items"][i]["link"]
   #                  else
   #                      color_image_hash[color] = [data["items"][i]["link"]]
   #                  end
   #              end
   #              # data["items"][0]["image"]["height"]
   #              # data["items"][0]["image"]["width"]
   #          end
   #      end
   #      @image_hash = color_image_hash
   #      return color_image_hash
   #  end

   def initialize(search_term)
    @search_term = search_term
  end

  def test_timeout
    timeout_in_seconds = 1
    5.times do 
      begin
        Timeout::timeout(timeout_in_seconds) do
          #Do something that takes long time
          sleep(3)
          puts "didnt' time out"
        end
      rescue Timeout::Error
        # Too slow!!
        puts "oh no! Timeout!!"
      end 
    end
  end

    def get_pictures
      @photo_tiles = ImageList.new
      limit = 500
      photos_per_query = 10
      api_key = "AIzaSyBqHvq5UeKEtmOVSGZ0vWrjKK1YGRS_4k8"
      timeout_in_seconds = 1
      # start = 1
      (1..limit).step(photos_per_query) { |start|
        puts "getting photos"
        puts "start is: #{start}"
        source = "https://www.googleapis.com/customsearch/v1?q=#{self.search_term}&cx=012238431153746656688%3Ai-xqvgd0-hq&num=#{photos_per_query}&searchType=image&start=#{start}&key=#{api_key}"
        # source = "https://www.googleapis.com/customsearch/v1?q=#{search_term}&cx=012238431153746656688%3Ai-xqvgd0-hq&num=#{photos_per_query}&searchType=image&key=#{api_key}"
        # (res = Net::HTTP.get_response(URI.parse(URI.escape(url)))) rescue puts 'Cannot reach to URL'
        # data = XmlSimple.xml_in(res.body, { 'ForceArray' => false })['resultset_images']['result']
        data = JSON.load(open(source))
        (0...photos_per_query).each {|i|
            puts "reading photos"
            @photo_tiles.read(data["items"][i]["link"]) rescue puts 'Cannot read image'
      }
      } rescue 'no more images found'
    end

    def resize_pictures
      l = ImageList.new
      self.photo_tiles.scene = 0
      (0...self.photo_tiles.length).each do |i|
        l << self.photo_tiles.resize_to_fill!(15,15)
        self.photo_tiles.scene += 1 rescue self.photo_tiles.scene = 0
      end
      @resized_photo_tiles = l
    end

    def average_color(image)
      red, green, blue = 0, 0, 0
      image.each_pixel do  |pixel, c, r|
        red += pixel.red
        green += pixel.green
        blue += pixel.blue
      end
    num_pixels = image.rows * image.columns
    return [red/num_pixels, green/num_pixels, blue/num_pixels]
    end

    def average_color_list
      @photo_tile_colors = []
      (0...resized_photo_tiles.length).each do |i|
        @photo_tile_colors << self.average_color(self.resized_photo_tiles[i])
      end
    end

    def complete_search
      puts "getting pictures"
      self.get_pictures
      puts "resizing pictures"
      self.resize_pictures
      puts "getting picture colors"
      self.average_color_list
    end

    # def create_link_array(image)
    #   img_list = []
    #   color_image_hash = self.object_hash
    #   pixel_list = image.color_list
    #   pixel_list.each do |pixel|
    #      img = color_image_hash[pixel].sample #account for invalid links
    #      img_list << img
    #   end
    #   @image_list = img_list
    # end

    # def create_image_list_for_hash(image)
    #   img_list = []
    #   self.image_hash.each do |color, image|
    #     img_list << image
    #   end
    #   return img_list
    # end

    # def photos_for_example(photos)
    #   l = Magick::ImageList.new
    #   photos.each do |p|
    #       begin 
    #         puts "opening picture in ruby"
    #         urlimage = open(p)
    #         puts "reading image into imagemagick"
    #         l.from_blob(urlimage.read)
    #         puts "done with image #{p}"
    #       rescue
    #         picture
    #       end
    #   end
    #   return l
    # end

    




    
    # def create_conversion_hash(photos) #hash of photo links to photo objects
    #   conversion_hash = {}
    #   l = Magick::ImageList.new
    #   i = 0
    #   photos.uniq.each do |p|
    #       begin 
    #         puts "opening picture in ruby"
    #         urlimage = open(p)
    #         puts "reading image into imagemagick"
    #         l.from_blob(urlimage.read)
    #         puts "done with image #{p}"
    #         conversion_hash[p] = l[i]
    #         i += 1
    #       rescue

    #       end
    #   end
    #   @conversion_hash = conversion_hash
    #   return conversion_hash
    # end

    # def convert_link_array_to_objects(link_array) #returns an array of photos objects
    #   l = Magick::ImageList.new
    #   link_array.each do |p|
    #     l << self.conversion_hash[p].copy.resize_to_fill!(13,13)
    #   end
    #   return l
    # end
end
