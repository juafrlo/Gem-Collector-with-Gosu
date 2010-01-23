begin
  # In case you use Gosu via rubygems.
  require 'rubygems'
rescue LoadError
  # In case you don't.
end

module ZOrder
  Background, Player, Map, Gem, Score = *0..5
end

require 'gosu'
include Gosu
require 'map'
require 'collectible_gem'
require 'player'
require 'enemy'
require 'title'

class Game < Window
  attr_reader :map

  def initialize
    super(640, 480, false)
    self.caption = "Jumper man"
    @map = Map.new(self, "media/map.txt")
    @title = Title.new(self)
    @player = Player.new(self, 600, 495)
    # Scrolling is stored as the position of the top left corner of the screen.
    @screen_x = @screen_y = 0
    # Font for the score
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20) 
    @jump = Gosu::Sample.new(self, "media/jump.wav")
    @player.status = "starting"
    @background = Gosu::Song.new(self, "media/background.wav")
    @background.play(true)
  end
  
  def update
    if @player.status == "starting"
      @player.status = "alive" if button_down? KbSpace
    else
      move_x = 0 #Initialites this variable, for horizontal movement
      # Now a value of 5 is assigned. It determinates the velocity of the game
      # when walking, because there is a loop 5.times to check if the player has to
      # move 1px to that position
      move_x -= 5 if button_down? KbLeft
      move_x += 5 if button_down? KbRight
    
      # Updates current image to show of player and its position
      if @player.status == "alive"
        @player.update(move_x) 
        # Quits gems when distance < 50
        @player.collect_gems(@map.gems) 
      end
    
      if @map.gems.size == 0 
        @font.draw("You win!", 180, 140, ZOrder::Score, 4.0, 4.0, 0xffffff00)
        @font.draw("Game developed by Juan de Frías", 185, 230, ZOrder::Score, 1.0, 1.0, 0xffffff00)
        @font.draw("For more info visit http://www.juandefrias.com", 134, 250, ZOrder::Score, 1.0, 1.0, 0xffffff00)     
        @font.draw("Press ESC to exit", 260, 280, ZOrder::Score, 1.0, 1.0, 0xffffff00)     
        @player.status = "finish"
      end  
    
      @map.enemies.each do |e|
        if e.status == "alive"
          e.update(2)      
          e.draw(@screen_x, @screen_y) 
          e.kills_player?(@player) if @player.status == "alive"
        else
          @map.enemies.delete(e) 
        end
      end
    
    
      # Scrolling follows player
      # @screen_x and @screen_y are the upper left corners of the map to draw
      # @map dimensions depend of file.(width and height) Each tile is 50x50px
      # We want to the player to show on the center of screen, so the upper left
      # corner of the map is @player.position - resolution of screen / 2, but
      # never minor to [0,0], whre there is no map and never bigger
      # than the map (map.width * 50 - screen_size gives upper left position)
      # Example
      # @screen_x = [400 - 320,0].max, [2700 - 640]].min
      # @screen_x = [80,2060].min
      # @screen_x = 80
      @screen_x = [[@player.x - 320, 0].max, @map.width * 50 - 640].min
      @screen_y = [[@player.y - 240, 0].max, @map.height * 50 - 480].min
    end
  end

  def draw
    if @player.status == "starting"
      @title.draw(@font)
    else 
      @map.draw @screen_x, @screen_y
      if @player.status == "alive"
        @player.draw @screen_x, @screen_y 
      elsif @player.status == "dead"
        @font.draw("Game over", 140, 170, ZOrder::Score, 4.0, 4.0, 0xffffff00)
        @font.draw("Lives left: #{@player.lives}", 290, 250, ZOrder::Score, 1.0, 1.0, 0xffffff00)
        if  @player.lives > 0
          @font.draw("Press ENTER to continue", 225, 280, ZOrder::Score, 1.0, 1.0, 0xffffff00)
          if button_down? KbReturn 
            @player.status = "alive"        
          end
        else
          @font.draw("For more info visit http://www.juandefrias.com", 134, 280, ZOrder::Score, 1.0, 1.0, 0xffffff00)     
          @font.draw("Press ESC to exit", 260, 310, ZOrder::Score, 1.0, 1.0, 0xffffff00)
        end
      end
      @font.draw("Points: #{@player.score}", 10, 10, ZOrder::Score, 1.0, 1.0, 0xffffff00) 
      @font.draw("Gems left: #{@map.gems.size}", 10, 30, ZOrder::Score, 1.0, 1.0, 0xffffff00) 
    end
  end

  def button_down(id)
    if id == KbUp then @player.try_to_jump and @jump.play end
    if id == KbEscape then close end
  end
end


#Main program
Game.new.show
