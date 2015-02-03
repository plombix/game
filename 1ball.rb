require 'rubygems'
require 'gosu'
require 'pry'
require 'pry-debugger'

class GameWindow <Gosu::Window

  def initialize
    super(1620, 1024, false)

    #############VarInit
    @seed= [] ; while @seed.count< 21 ; @seed<<rand(1..30)*15; end;
    @bulletrain = @bulletfall = @bulletchain = @badguy = @hardguy= []
    @frame = @totaltime = @skrolIndex = 0
    @gameState = 0          # 0 = Start menu  1 = Game in progress  2 = Game in pause  3 = Game in end of day 4 = Game in mana
    #############Sounds
    @wait_a_min = Gosu::Sample.new(self, "sound/wait-a-minute.wav")
    @pew = Gosu::Sample.new(self, "sound/pew1.wav")
    #############Texts
    self.caption = "_-{]   BalanceD   [}-_"
    @start_text1 = Gosu::Image.from_text(self,"_-{]  Entree pour Commencer  [}-_", "font/simple.TTF",  55)
    @start_text2 = Gosu::Image.from_text(self,"_-{]    Escape pour Quitter    [}-_", "font/simple.TTF",  55)
    @continue = Gosu::Image.from_text(self,"_-{]  Entree pour Continuer  [}-_", "font/simple.TTF",  55)
    @quit= Gosu::Image.from_text(self,"_-{]  P pour Quitter  [}-_", "font/simple.TTF",  55)
    # @count2 = Gosu::Image.from_text(self,"_-{]  2  [}-_", "font/simple.TTF",  55)
    # @count1 = Gosu::Image.from_text(self,"_-{]  1  [}-_", "font/simple.TTF",  55)
    # @count0 = Gosu::Image.from_text(self,"_-{]  GO!  [}-_", "font/simple.TTF",  55)
    #############Images/Anims
    @current_balance = Gosu::Font.new(self, "font/simple.TTF",  70)
    @background_image = Gosu::Image.new(self, "img/bg_starVII.png", false)
    @starscroll = Gosu::Image.new(self,"img/StarFar.png", false)
    # @starscrollsp = Gosu::Image.new(self,"img/Starclose.png", false)
    @startBackground = Gosu::Image.new(self, "img/Title.png", false)
    @damageFire = Gosu::Image.load_tiles(self, "img/SpriteHit.png", 96,96, false)
    #############Entity
    @player = Player.new(self)
    # @badguy = Enemy.new(self , 1 ,1,1)
    # @hardguy << Cruiser.new(self , srand(100,1620),@seed[2])
    @badguy << Fighter.new(self ,self.width/10,@seed[0])<< Assault.new(self , (width/10)*2,@seed[1])<< Fighter.new(self , (width/10)*4,@seed[3]) << Fighter.new(self , (width/10)*5,@seed[4]) << Fighter.new(self , (width/10)*6,@seed[5]) << Fighter.new(self , (width/10)*7,@seed[6]) << Fighter.new(self , (width/10)*8,@seed[7]) << Fighter.new(self , (width/10)*9,@seed[8])
  end

  def up_frame
    @frame +=1
    @skrolIndex +=10
    if @skrolIndex >= 0 then @skrolIndex = -@starscroll.height+1024 end
    # if @frame > 99 then @frame = 0 end
  end
  def frameReset
    @frame = 0
  end
  def frame
    @frame
  end



  def update
    self.up_frame
    if @gameState == 0                                                 # 0 = Start menu
      if button_down? Gosu::KbReturn
        @gameState = 1
      elsif button_down? Gosu::KbEscape
        close
      end
    elsif @gameState == 1                                              # 1 = Game in progress
      # if @badguy.size == 0
      #      @badguy << Fighter.new(self ,self.width/10,@seed[0]-200)<< Assault.new(self , (width/10)*2,@seed[1]-200)<< Cruiser.new(self , (width/10)*3,@seed[2]-200) << Fighter.new(self , (width/10)*4,@seed[3]-200) << Fighter.new(self , (width/10)*5,@seed[4]-200) << Fighter.new(self , (width/10)*6,@seed[5]-200) << Fighter.new(self , (width/10)*7,@seed[6]-200) << Fighter.new(self , (width/10)*8,@seed[7]-200) << Fighter.new(self , (width/10)*9,@seed[8]-200)
      # end
      @badguy.reject! {|x| x.energy <= 0}
      @badguy.reject! {|x| x.y>=self.height}
      @totaltime += 1
      if button_down? Gosu::KbEscape
        # @wait_a_min.play
        @gameState = 2
        self.frameReset
      end
      @player.warp(mouse_x, mouse_y)
      @badguy.each do |x|
        x.move(x.x, x.y)
      end
      if@frame % 30 == 0
        @badguy.each {|x| @bulletfall<<x.shoot(self)}
      end

      if button_down? Gosu::MsLeft
        if @frame % @player.shootSpeed ==0
          @bulletrain<< Bullet.new(self ,@player.x-12, (@player.y-20))
          @player.balance_down 1
          # @pew.play
        end
      end
      if button_down? Gosu::MsRight
        if @frame % (@player.shootSpeed*1.5) ==0
          @bulletrain<< BulletM.new(self ,@player.x-32, (@player.y-20))
          @player.balance_down 10
          # @pew.play
        end
      end
    elsif @gameState == 2                                         # 2 = Game in pause
      if button_down? Gosu::KbReturn
        sleep(0.5)
        @gameState = 1
      elsif button_down? Gosu::KbP
        close
      end
    end
  end
  def draw
    if @gameState == 0                                                 # 0 = Start menu
      @startBackground.draw_as_quad(0, 0, 0xffffffff, self.width, 0, 0xffffffff, self.width, self.height, 0xffffffff, 0, self.height, 0xffffffff, 0)
      @start_text1.draw width/2 - @start_text1.width/2, height- 170, 10
      @start_text2.draw width/2 - @start_text2.width/2, height- 100, 10
    elsif @gameState == 1                                              # 1 = Game in progress
      @background_image.draw_as_quad(0, 0, 0xffffffff, self.width, 0, 0xffffffff, self.width, self.height, 0xffffffff, 0, self.height, 0xffffffff, 0)
      @starscroll.draw(0,@skrolIndex,1)
      @current_balance.draw(@player.balance,0,0,2)
      @player.draw
      # unless @badguy.empty?
      #   @badguy.each do |x|
      #     x.draw(x.x, x.y)
      #   end
      # end
      unless @bulletrain.empty?
        @bulletrain.each do |x|
          x.draw
          if x.y <= 0
            @bulletrain = @bulletrain.drop(1)
          end
          @badguy.each do |o|
            if o.limits?((x.x.round)..(x.x.round+x.width), (x.y.round)..(x.y.round+x.height))
              o.hit x.pow
              @damageFire.each do |s|; s.draw(x.x-s.width/2+x.width/2, x.y-s.height, 4); end
              @bulletrain = @bulletrain.drop(1)
            end
          end
        end
      end
      unless @bulletfall.empty?
        @bulletfall.each {|x|x.draw}
      end
    elsif @gameState == 2                                              # 2 = Game in pause
      @background_image.draw_as_quad(0, 0, 0xeeeeeee, self.width, 0, 0xeeeeeee, self.width, self.height, 0xeeeeeee, 0, self.height, 0xeeeeeee, 0)
      @continue.draw width/2- @continue.width/2 , height/2- @continue.height/2, 1
      @quit.draw width/2- @quit.width/2 , height/2- @quit.height/2 + @quit.height, 1
    end
  end



  def button_down(id )
    if id == Gosu::MsWheelUp
      @player.increaseShootSpeed
    end
    if id == Gosu::MsWheelDown
      @player.decreaseShootSpeed
    end
  end
end


class Player
  def initialize (window)
    @image = Gosu::Image.new(window, "img/Starship.png" ,false)
    @x = @y = @vel_x = @vel_y = @angle =0.0
    @score = 0
    @shootSpeed = 5
    @balance = 1000
    @energy = 1000
  end
  def energy;                    @energy; end
  def hurt (x);                @energy -= x ;end
  def warp (x, y) ;          @x = x ;@y = y ;end
  def move_left;                self.warp(@x-10, @y); end
  def move_right;           self.warp(@x+10, @y); end
  def move_up ;                self.warp(@x, @y-10); end
  def move_down;                self.warp(@x, @y+10); end
  def accelerate;           @vel_x += Gosu::offset(@angle, 0.5); @vel_y += Gosu::offset(@angle, 0.5); end
  def decelerate;           @vel_x += Gosu::offset(@angle, -0.5); @vel_y += Gosu::offset(@angle, -0.5); end
  def draw;                     @image.draw_rot(@x, @y, 1, @angle); end
  def x;                          @x; end
  def y;                         @y;end
  def shootSpeed ;           @shootSpeed ; end
  def increaseShootSpeed; if@shootSpeed >1; @shootSpeed-=1; end; end
  def decreaseShootSpeed; if @shootSpeed < 20 ; @shootSpeed+=1 ; end ; end
  def balance_down( x );      @balance-=x; end
  def current_balance;     @current_balance;end
  def balance;               @balance;end

  # def limits? (x,y)
  #      if x.any? {|o| (@x.round..(@x.round + @image.width)).include? o } && y.any? {|i| (@y.round..(@y.round + @image.height)).include? i }
  #           true
  #      end
  # end
end
class Bullet
  def initialize(window ,x, y)
    @bullet = Gosu::Image.new(window, "img/JellyGreen.png", false)
    @pow = 1
    @x ,@y = x,y
    @bulVel_x , @bulVel_y = 1
  end
  def draw ;                    @bullet.draw @x,@y-=30,0 ;end
  def x ;                         @x ;end
  def y ;                         @y ;end
  def width ;                         @bullet.width ;end
  def height ;                         @bullet.height ;end
  def pow;                    @pow     ;end

end

class BulletM <Bullet
  def initialize(window ,x, y)
    super
    @bullet = Gosu::Image.new(window, "img/JellyBlueM.png", false)
    @pow = 5
  end
  def draw ;                    @bullet.draw @x,@y-=15,0 ;end
end

class FighterBullet1<Bullet
  def initialize(window ,x, y)
    super
    @bullet = Gosu::Image.new(window,"img/FighterBullet1.png")
    @pow = 5
    @speed = 40
  end
  def draw;                     @bullet.draw @x ,@y +=10, 0 ;end
end

class AssaultBullet1<Bullet
  def initialize(window ,x, y)
    super
    @bullet = Gosu::Image.new(window,"img/AssaultBullet1.png")
    @pow = 5
    @speed = 40
  end
  def draw ;                    @bullet.draw @x,@y+=10,0 ;end
end
class AssaultBullet2<Bullet
  def initialize(window ,x, y)
    super
    @bullet = Gosu::Image.new(window,"img/AssaultBullet2.png")
    @pow = 5
    @speed = 40
  end
  def draw ;                    @bullet.draw @x,@y+=10,0 ;end
end
class CruiserBullet1<Bullet
  def initialize(window ,x, y)
    super
    @bullet = Gosu::Image.new(window,"img/CruiserBullet1.png")
    @pow = 5
    @speed = 40
  end
  def draw ;                    @bullet.draw @x,@y+=10,0 ;end
end
class CruiserBullet2<Bullet
  def initialize(window ,x, y)
    super
    @bullet = Gosu::Image.new(window,"img/CruiserBullet2.png")
    @pow = 5
    @speed = 40
  end
  def draw ;                    @bullet.draw @x,@y+=10,0 ;end
end
class Enemy
  def initialize(window, x, y)
    @x = x
    @y = y
    @max_energy = 10
    @moveSpeed = 1
    @energy = @max_energy
    @shootSpeed = 10
    @image = Gosu::Image.new(window,"img/Enemy1.png")
  end
  def draw (x,y)
    @image.draw(x,y,0)
  end
  def x;                          @x; end
  def y;                          @y; end
  def move (x,y);           @x= x; @y  += (Math.sin(Gosu::milliseconds / 133.7))+@moveSpeed;end
  def energy ;               @energy; end
  def hit (pow)
    @energy -= pow
  end
  def limits? (x,y)
    if x.any? {|o| (@x.round..(@x.round + @image.width)).include? o } && y.any? {|i| (@y.round..(@y.round + @image.height)).include? i }
      true
    end
  end
  def height
    @image.height
  end
end

class Fighter <Enemy
  def initialize(window, x, y)
    super
  end
  def shoot (window)
    FighterBullet1.new(window,@x+@image.width/2, @y+@image.height)
  end
end

class Assault <Enemy
  def initialize(window, x, y)
    super
    @max_energy = 15
    @moveSpeed = 1
    @energy = @max_energy
    @shootSpeed = 8
    @image = Gosu::Image.new(window,"img/Enemy2.png")
  end
  def move (x,y);           @x= x; @y = y + @moveSpeed; end
  def shoot(window)
    AssaultBullet1.new(window,@x+@image.width/2, @y+@image.height)
  end
end
class Cruiser<Enemy
  def initialize(window, x, y)
    super
    @moveSpeed = 1
    @max_energy = 50
    @energy = @max_energy
    @shootSpeed = 5
    @image = Gosu::Image.new(window,"img/Enemy3.png")
    @windowWidth = window.width
  end
  def move (x,y)
    @x = ((@windowWidth/2)- @image.width) + (Math.sin(Gosu::milliseconds / 1333.7)*((@windowWidth/2)- @image.width))
    @y =  y += 1
  end
  def shoot (window)
    CruiserBullet1.new(window,@x+@image.width/2, @y+@image.height)
  end
end
window = GameWindow.new
window.show
