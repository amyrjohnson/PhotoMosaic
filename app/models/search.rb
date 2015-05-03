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
      limit = 50
      photos_per_query = 10
      api_key = "AIzaSyCHSKFAq4jNSLXBFD-0X_In1gwsYimZbVc"
      id = "012238431153746656688:i-xqvgd0-hq"
      timeout_in_seconds = 1
      threads = []
      # start = 1
      (1..limit).step(photos_per_query) { |start|
        puts "getting photos"
        puts "start is: #{start}"
        source = "https://www.googleapis.com/customsearch/v1?q=#{self.search_term}&cx=#{id}&num=#{photos_per_query}&searchType=image&start=#{start}&key=#{api_key}&imageSize=Medium&fileType=jpg"
        #puts source
        #source = "https://www.googleapis.com/customsearch/v1?q=#{search_term}&cx=#{id}&num=#{photos_per_query}&searchType=image&key=#{api_key}"
        data = JSON.load(open(source))
        (0...photos_per_query).each {|i|
            #@photo_tiles.read(data["items"][i]["image"]["thumbnailLink"]) rescue puts 'Cannot read image'
            #@photo_tiles.read(data["items"][i]["link"]) rescue puts 'Cannot read image'
            threads << Thread.new { 
               open("tmp/image_#{start}_#{i}", 'wb') do |file|
                 file << open(data["items"][i]["image"]["thumbnailLink"]).read rescue puts 'Cannot read image'
               end
             }
            
        }
      } rescue 'no more images found'

      threads.each do |t|
         t.join
      end

      (1..limit).step(photos_per_query) do |start|
         (0...photos_per_query).each do |i|
          puts "reading tmp/image_#{start}_#{i}"
          @photo_tiles.read("tmp/image_#{start}_#{i}") rescue puts 'Cannot read image'
         end
      end
    end

    def resize_pictures(length, width)
      l = ImageList.new
      self.photo_tiles.scene = 0
      (0...self.photo_tiles.length).each do |i|
        l << self.photo_tiles.resize_to_fill!(length,width)
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

    def complete_search(tile_length, tile_width)
      puts "getting pictures"
      time = Time.now
      self.get_pictures
      time2 = Time.now
      puts "Getting pictures took #{time2 - time}"
      puts "resizing pictures"
      self.resize_pictures(tile_length, tile_width)
      time3 = Time.now
      puts  "resizing pictures took #{time3 - time2}"
      puts "getting picture colors"
      self.average_color_list
      time4 = Time.now 
      puts "getting picture colors took #{time4 - time3}"
    end

end
