class CollectibleGem
  attr_reader :x, :y

  def initialize(image, x, y)
    @image = image
    @x, @y = x, y
  end
  
  def draw(screen_x, screen_y)
    # Draw, slowly rotating
    if (@x - screen_x) > -50 and (@x - screen_x) <= 640 and
      (@y - screen_y) > -50 and (@y - screen_y) <= 480 then
        @image.draw_rot(@x - screen_x, @y - screen_y, ZOrder::Gem,
          25 * Math.sin(milliseconds / 133.7))
    end
  end
end
