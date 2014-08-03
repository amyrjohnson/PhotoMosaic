require 'open-uri'
require 'json'

class Search

   def self.get_pictures(color_hash, search_term)
        color_image_hash = {}
        api_key = "AIzaSyBqHvq5UeKEtmOVSGZ0vWrjKK1YGRS_4k8"

        color_hash.each do |color, count|
            source = "https://www.googleapis.com/customsearch/v1?q=#{search_term}&cx=012238431153746656688%3Ai-xqvgd0-hq&imgDominantColor=#{color}&searchType=image&key=#{api_key}"
            data = JSON.load(open(source))

            (0..count).each do |i|
                if data["items"][i]
                    if color_image_hash[color]
                        color_image_hash[color] << data["items"][i]["link"]
                    else
                        color_image_hash[color] = [data["items"][i]["link"]]
                    end
                end
                # data["items"][0]["image"]["height"]
                # data["items"][0]["image"]["width"]
            end
        end
        return color_image_hash
    end

end