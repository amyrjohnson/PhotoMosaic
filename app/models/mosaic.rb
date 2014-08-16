class Mosaic

  def order_photos(photos, rows, cols)
      page = Magick::Rectangle.new(0,0,0,0)
      photos.scene = 0

      r = rows - 1
      c = cols -1

      (0..r).each do |row_number|
        (0..c).each do |col_number|
          puts "row number is #{row_number}, col number is #{col_number}"

          page.x = col_number * 15
          page.y = row_number * 15
          puts "page is #{page}"
          puts "current photo is #{photos.cur_image.inspect}"
          photos.page = page
          puts "photos.page is now #{photos.page}"
          puts "current_image.page is now #{photos.cur_image.page}"

          photos.scene += 1 rescue photos.scene == 0
          puts "photo scene has been updated to #{photos.scene}"
        end
      end
      return photos
  end

  def create_mosaic(image_list)
    m = image_list.mosaic
    m.write("mosiac.gif")
  end

end
