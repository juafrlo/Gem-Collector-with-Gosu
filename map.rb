module Tiles
  Grass = 0
  Earth = 1
end

class Map
  attr_reader :width, :height, :gems, :enemies
  
  def initialize(window, filename)
    # Load 60x60 tiles, 5px overlap in all four directions.
    # That means 60x60px, and player walks 5px inside this 60x60px
    @tileset = Image.load_tiles(window, "media/tileset.png", 60, 60, true)
    # Loads background
    @sky = Image.new(window, "media/sky.png", true)
    # Loads gem image 
    gem_img = Image.new(window, "media/gem.png", false)
    @gems = []    
    #Loads enemies image
    enemy_imgs = *Image.load_tiles(window, "media/enemy.png", 50, 50, false)
    @enemies = []
    
    #Read txt file
    lines = File.readlines(filename).map { |line| line.chomp }
    @height = lines.size
    @width = lines[0].size
    # Reads the lines array, character by character
    # Returns and array with all the map converted to game language
    # @tiles is an array of 1s (grass), 0s (earth) and nils (nothing)
    @tiles = Array.new(@width) do |x|             
      Array.new(@height) do |y|
        case lines[y][x, 1]
        when '"'
          Tiles::Grass
        when '#'
          Tiles::Earth
        when 'x'
          @gems.push(CollectibleGem.new(gem_img, x * 50 + 25, y * 50 + 25))
          nil
        when 'e'
          @enemies.push(Enemy.new(window,self,enemy_imgs, x * 50 + 25, y * 50 + 25))
          nil          
        else
          nil
        end
      end
    end
  end
  
  def draw(screen_x, screen_y)
    @sky.draw(0, 0, ZOrder::Background) # Here the background is drawn

    # Very primitive drawing function:
    # Draws all the tiles, some off-screen, some on-screen.
    @height.times do |y|
      @width.times do |x|
        tile = @tiles[x][y]
        if tile
          # Screen is always from (0,0) to (640,480), but map is bigger
          # When something is drawn, is always drawn on positions between (0,0) and (640,480)
          # So something.x and something.y must be in (640,480) to appear on screen
          # @tileset is and array with two images
          # Draw the tile with an offset (tile images have some overlap)
          # Scrolling is implemented here just as in the game objects.
          # x and y are numbers: They are an array position
          # screen_x and screen_y are for scrolling, adn are the map position on px
          # So screen_x and screen_y can be bigger to (0,0)-(640,480)
          # Onlu things between (0,0)-(640,480) is shown on screen
          # -5 is for correction
          # This does not draws gems; only tiles
          if (x*50 - screen_x - 5) > -50 and (x*50 - screen_x -5) <= 640 and
            (y*50 - screen_y -5) > -50 and (y*50 - screen_y -5) <= 480
            @tileset[tile].draw(x * 50 - screen_x - 5, y * 50 - screen_y - 5, ZOrder::Map)
          end
        end
      end
    end
    #Draw gems with collectible_gem.draw method
    @gems.each { |c| c.draw(screen_x, screen_y) }
  end
  
  # Solid at a given pixel position?
  # @tiles is an array of 1s (grass), 0s (earth) and nils (Earth)
  # Each tile is 50x50 ps (without overlap)
  # A map is solid when has y < 0 or @tiles returns 0(grasss) or 1 (earth)
  # In Ruby, boolean false is false and nil, but -1,0 and 1 are true
  # x and y are positions
  # if x = 100 and y = 100, return @tiles[1][1], that can be 0,1 or nil
  
  def solid?(x, y)
    y < 0 || @tiles[x / 50][y / 50]
  end
end
