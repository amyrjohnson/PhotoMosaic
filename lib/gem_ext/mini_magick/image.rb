module MiniMagick
  class Image
    def pixel_at(x, y)
      case run_command("convert", "#{escaped_path}[1x1+#{x}+#{y}]", "-depth 8", "txt:").split("\n")[1]
      when /^0,0:.*(#[\da-fA-F]{6}).*$/ then $1
      else nil
      end
    end

    def escaped_path
        Pathname.new(@path).to_s.gsub(" ", "\\ ")
    end
  end
end
