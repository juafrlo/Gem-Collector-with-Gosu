class Enemy
  attr_reader :x, :y, :status
  
  def initialize(window,map,images, x, y)
    @x, @y = x, y - 20
    @vy = 0
    @map = map
    @dir = :right
    @standing, @walk1, @walk2, @jump = images
    @cur_image = @standing    
    @status = "alive"
    @dead = Gosu::Sample.new(window, "media/dead.wav")
  end
  
  def draw(screen_x, screen_y)
    @cur_image.draw(@x - screen_x, @y - screen_y - 7, ZOrder::Gem)
  end
  
  def would_fit(offs_x, offs_y)
    if @vy > 0 
      not @map.solid?(@x,@y+50)
    else
      not @map.solid?(@x + 50,@y)       
    end
  end
  
  def update(move_x)
    # Directional walking, horizontal movement
    if @vy == 0
      if move_x > 0 
        @cur_image = (milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
      end
      if @dir == :right then
        if !@map.solid?(@x + 50, @y + 50) || @map.solid?(@x+55,@y)
          @dir = :left
        else
          # If there is nothing (linke grass or earch, player can be placed there)
          # It uses (1,0) because it checks 1px horizontal
          move_x.times do          
            if would_fit(1, 0) 
              @x += 1 
            end 
          end
        end
      end
      if @dir == :left then
        if !@map.solid?(@x - 2, @y + 50) || @map.solid?(@x -5 ,@y)
          @dir = :right
        else
          move_x.abs.times do  
            if would_fit(-1, 0)         
              @x = @x -1  
            end
          end
        end
      end
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
  end
  
  def kills_player?(player)
    if @y > player.y - 40 && (@y - player.y - 40) < 5 &&
     player.vy > 1 &&
      ( ((x - player.x) > -25 && (x - player.x  ) < 0) || ((x-player.x) > -45 && (x-player.x)<0))
      @status = "dead"
      @dead.play
    elsif (player.y - @y == 40 || player.y - @y == 44) && 
      ( ((x - player.x) > -25 && (x - player.x  ) < 0) || ((x-player.x) > -45 && (x-player.x)<0))
      player.lives -= 1 if player.status != "dead"
      @dead.play
      player.status = "dead"
    end
  end
  
end