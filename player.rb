class Player
  attr_reader :x, :y
  attr_accessor :status, :vy, :lives, :score

  def initialize(window, x, y)
    @x, @y = x, y
    @dir = :left
    @vy = 0 # Vertical velocity
    @map = window.map
    # Load all animation frames
    @standing, @walk1, @walk2, @jump =
      *Image.load_tiles(window, "media/player.png", 50, 50, false)
    # This always points to the frame that is currently drawn.
    # This is set in update, and used in draw.
    @cur_image = @standing    
    @score = 0
    #Sound to play when player collects a gem
    @beep = Gosu::Sample.new(window, "media/Beep.wav")
    @status = "alive"
    @lives = 3
  end
  
  def draw(screen_x, screen_y)
    # Flip vertically when facing to the left.
    if @dir == :left then
      offs_x = -25
      factor = 1.0
    else
      offs_x = 25
      factor = -1.0
    end
    @cur_image.draw(@x - screen_x + offs_x, @y - screen_y - 49, ZOrder:: Player, factor, 1.0)
  end
  
  # Could the object be placed at x + offs_x/y + offs_y without being stuck?
  def would_fit(offs_x, offs_y)
    # Check at the center/top and center/bottom for map collisions
    # Only returns true with not nil and not nil,  
    # wich means there is nothing in this position of the map
    not @map.solid?(@x + offs_x, @y + offs_y) and
      not @map.solid?(@x + offs_x, @y + offs_y - 45) and
      not @map.solid?(@x + offs_x + 15 , @y + offs_y) and
      not @map.solid?(@x + offs_x - 15 , @y + offs_y) 
  end
  
  def update(move_x)
    # Select image depending on action
    if (move_x == 0)
      @cur_image = @standing
    else
      # Outputs one image or other image dependieng on time
      # milliseconds is a tomer that alwaysis incrementing
      @cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
    end
    if (@vy < 0)
      @cur_image = @jump
    end
    
    # Directional walking, horizontal movement
    if move_x > 0 then
      @dir = :right
      # If there is nothing (linke grass or earch, player can be placed there)
      # It uses (1,0) because it checks 1px horizontal
      move_x.times { if would_fit(1, 0) then @x += 1 end }
    end
    if move_x < 0 then
      @dir = :left
      (-move_x).times { if would_fit(-1, 0) then @x -= 1 end }
    end

    # Acceleration/gravity
    # By adding 1 each frame, and (ideally) adding vy to y, the player's
    # jumping curve will be the parabole we want it to be.
    @vy += 1
    # Vertical movement
    if @vy > 0 then
      # It uses (0,1) because it checks 1px vertical
      # In horizontal, when walking, would_fit(0,1) returns false, because
      # would_fit be always the floor, witch means 0 or 1 (grass or earth)
      # Rembember @y > 0 means pixels from upper left corner
      @vy.times { if would_fit(0, 1) then @y += 1 else @vy = 0 end }
    end
    if @vy < 0 then
      # If player hits grass or earth when jumping,
      # player will not move vertically
      (-@vy).times { if would_fit(0, -1) then @y -= 1 else @vy = 0 end }
    end
  end
  
  # Tries to jump, if map position @x (upper left of the player)
  # and @y (upper left of the player) +1px is nil
  # Uses @y+1 because player only can jump if is on the floor
  # WIth +1, the division of solid? gives and integer different
  #      ----------
  #      |   Map  |
  #      |        |
  #      ----------
  
  #      @x
  #       ----------
  #       | Player |
  #       |        |
  #       ----------

  #       @y +1
  #       ----------
  #       |  Floor |
  #       ----------


  def try_to_jump    
    if @vy == 0 && (@map.solid?(@x - 20, @y + 1) || @map.solid?(@x + 20, @y + 1)) then
      @vy = -20
    end
  end
  
  
  # Same as in the tutorial game.
  #    @x---------     c.x-----
  #    |  Player |     |  Gem |
  #    |         |     |      |
  #    -----------     --------
  #      200 < 50       50x50px
  # If abs(differnce between @x and c.x i<x), then one if over the other
  def collect_gems(gems)            
    gems.reject! do |c|
      if (c.x - @x).abs < 50 and (c.y - @y).abs < 50
        @beep.play
        @score += 100
      end
    end
  end  
end
