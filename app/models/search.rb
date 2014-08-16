require 'open-uri'
require 'json'
require 'timeout'

class Search

    require 'RMagick'
    include Magick

  # attr_accessor :image_hash, :image_list, :resized_pictures, :object_hash, :conversion_hash, 
  attr_accessor :photo_tiles, :resized_photo_tiles, :photo_tile_colors, :search_term

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
      api_key = ENV["GOOGLE_API_KEY"]
      id = ENV["SEARCH_ENGINE_ID"]
      timeout_in_seconds = 1
      # start = 1
      (1..limit).step(photos_per_query) { |start|
        puts "getting photos"
        puts "start is: #{start}"
        source = "https://www.googleapis.com/customsearch/v1?q=#{self.search_term}&cx=#{id}&num=#{photos_per_query}&searchType=image&start=#{start}&key=#{api_key}"
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

end
