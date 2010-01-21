class Title
  def initialize(window)
    @title = Image.new(window, "media/sky.png", true) 
  end
  
  def draw(font)
    @title.draw(0, 0, ZOrder::Background)
    font.draw("Gem collector", 95, 170, ZOrder::Score, 4.0, 4.0, 0xffffff00)  
    font.draw("Developed by Juan de Frías", 202, 250, ZOrder::Score, 1.0, 1.0, 0xffffff00)
    font.draw("Press SPACE to start", 230, 280, ZOrder::Score, 1.0, 1.0, 0xffffff00)    
  end
end