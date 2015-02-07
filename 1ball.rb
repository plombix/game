require 'gosu'
require 'pry'
require 'rubygems'




################################################################################
##########################   MAIN GAME LOOP   ##################################
################################################################################


class GameWindow <Gosu::Window

  def initialize
    super(1620, 1024, false)

    #############VarInit
    @day =0
    @seed= [] ; while @seed.count< 21 ; @seed<<rand(1..30)*15; end;
    @bulletrain = []
    @bulletfall = []
    @bulletchain = []
    @badguy =  []
    @hardguy= []
    @phase =  0
    @frame = 0
    @totaltime = 0
    @skrolIndex = 0
    @total_balance = 0
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
    @dayEnd = Gosu::Font.new(self, "font/simple.TTF",  45)
    @balance = Gosu::Font.new(self, "font/simple.TTF",  45)
    @totalBalance = Gosu::Font.new(self, "font/simple.TTF",  45)
    @current_balance = Gosu::Font.new(self, "font/simple.TTF",  70)
    @current_energy = Gosu::Font.new(self, "font/simple.TTF",  70)
    @background_image = Gosu::Image.new(self, "img/bg_starVII.png", false)
    @starscroll = Gosu::Image.new(self,"img/StarFar.png", false)
    # @starscrollsp = Gosu::Image.new(self,"img/Starclose.png", false)
    @startBackground = Gosu::Image.new(self, "img/Title.png", false)
    @shop = Gosu::Image.new(self, "img/checkout.png", false)
    @preshop = Gosu::Image.new(self, "img/bilan.png", false)
    @damageFire = Gosu::Image.load_tiles(self, "img/SpriteHit.png", 96,96, false)
    #############Entity
    @player = Player.new(self)
    @badguy<< Fighter.new(self ,self.width/6,@seed[0])<< Fighter.new(self , (width/6)*2,@seed[1])<< Fighter.new(self , (width/6)*3,@seed[2])<< Fighter.new(self , (width/6)*4,@seed[3])<< Fighter.new(self , (width/6)*5,@seed[4])
  end

  def up_frame ;@frame +=1 ;@skrolIndex +=10 ;if @skrolIndex >= 0 then @skrolIndex = -@starscroll.height+1024 end ;end
  def frameReset; @frame = 0; end
  def frame; @frame; end

  def update
    self.up_frame
    if @gameState == 0                                                 # 0 = Start menu
      if button_down? Gosu::KbReturn; @gameState = 1; elsif button_down? Gosu::KbEscape; close; end
    elsif @gameState == 1                                              # 1 = Game in progress
      puts @gameState
      puts @phase
      ####################################### Basic movement an shooting states update
      @totaltime += 1
      if button_down? Gosu::KbEscape ;@gameState = 2 ;self.frameReset ;end
      @player.warp(mouse_x, mouse_y)
      @player.hurt_by(@bulletfall)
      if button_down? Gosu::MsLeft; if @frame % @player.shootSpeed == 0; @bulletrain<< Bullet.new(self ,@player.x-12, (@player.y-20)); @player.balance_down 1; end; end
      if button_down? Gosu::MsRight; if @frame % @player.shootSpeed == 0; @bulletrain<< BulletM.new(self ,@player.x-50, (@player.y-20));@player.balance_down 10 ;end;end
      @badguy.reject! {|x| x.energy <= 0 || x.y>=self.height}
      @bulletfall.reject! {|x| (x.y>=self.height)}
      @badguy.each do |x|
        x.move(x.x, x.y)
        x.hurt_by(@bulletrain)
        if@frame % x.shootSpeed == 0
          @bulletfall<<x.shoot(self)
        end
      end
      ######################################## Controlling game state by ennemy presence && setup of squads
      if @badguy.empty?
        @phase +=1
        if @phase == 1
          @badguy << Assault.new(self ,self.width/6,@seed[0])<< Assault.new(self , (width/6)*2,@seed[1])<< Assault.new(self , (width/6)*3,@seed[2])<< Assault.new(self , (width/6)*4,@seed[3])<< Assault.new(self , (width/6)*5,@seed[4])
        elsif @phase == 2
          @badguy  << Assault.new(self ,self.width/6,@seed[0])<< Fighter.new(self , (width/6)*2,@seed[1])<< Cruiser.new(self , (width/6)*3,@seed[2])<< Fighter.new(self , (width/6)*4,@seed[3])<< Assault.new(self , (width/6)*5,@seed[4])
        elsif @phase == 3
          @badguy << Fighter.new(self ,self.width/6,@seed[0] +70)<< Fighter.new(self , (width/6)*2,@seed[1] +70)<< Fighter.new(self , (width/6)*3,@seed[2] +70)<< Fighter.new(self , (width/6)*4,@seed[3] +70)<< Fighter.new(self , (width/6)*5,@seed[4] +70)<< Assault.new(self ,self.width/6,@seed[0])<< Fighter.new(self , (width/6)*2,@seed[1])<< Cruiser.new(self , (width/6)*3,@seed[2])<< Fighter.new(self , (width/6)*4,@seed[3])<< Assault.new(self , (width/6)*5,@seed[4])
        elsif @phase == 4
          @gameState = 3
        end
      end
    elsif @gameState == 2                                         # 2 = Game in pause
      if button_down? Gosu::KbReturn ;sleep(0.5) ;@gameState = 1 ;elsif button_down? Gosu::KbP ;close ;end
    elsif  @gameState == 3
      puts @gameState
      @day+=1
      @total_balance += @player.balance/100
      @gameState = 4
    elsif @gameState == 4
      if button_down? Gosu::KbReturn ;@gameState = 5;end
    end
    if @gameState == 5
      puts @gameState
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
      @current_energy.draw(@player.energy,0,100,2)
      @player.draw
      if @badguy
        @badguy.each do |x|
          x.draw(x.x , x.y)
        end
      end
      unless @bulletrain.empty?
        @bulletrain.each do |e|
          e.draw
          if e.y <= 0
            @bulletrain = @bulletrain.drop(1)
          end
        end
      end
      unless @bulletfall.empty?
        @bulletfall.each do |o|
          o.draw
        end
      end
    elsif @gameState == 2                                              # 2 = Game in pause
      @background_image.draw_as_quad(0, 0, 0xeeeeeee, self.width, 0, 0xeeeeeee, self.width, self.height, 0xeeeeeee, 0, self.height, 0xeeeeeee, 0)
      @continue.draw width/2- @continue.width/2 , height/2- @continue.height/2, 1
      @quit.draw width/2- @quit.width/2 , height/2- @quit.height/2 + @quit.height, 1
    elsif @gameState == 4
      @preshop.draw(0,0,0)
      @dayEnd.draw(           "_-{]  Bataille _-| #{@day} |-_ est finie !",50,20,1 )
      @balance.draw(          "_-{]  Ta reserve de balle est :    #{@player.balance}",50, 65,1)
      @totalBalance.draw(    "_-{]  Ton solde est :              #{@total_balance}",50,110,1)
      @continue.draw(50,600,1)
    elsif @gamestate == 5
      puts @gameState
      @shop.draw(0,0,0)
    end
  end
  ######################################## controlls whith no effects in phase or state gestion

  def button_down(id )
    if id == Gosu::MsWheelUp
      @player.increaseShootSpeed
    end
    if id == Gosu::MsWheelDown
      @player.decreaseShootSpeed
    end
  end
end
###################################### classes


class Player
  attr_accessor :x, :y, :energy
  attr_reader :balance ,:axx ,:axy
  def initialize (window)
    @dmg = Gosu::Image.new(window,"img/dmg.png", false)
    @image = Gosu::Image.new(window, "img/StarshipHbox.png" ,false)
    @axy = @axx = @x = @y = @vel_x = @vel_y = @angle =0.0
    @score = 0
    @shootSpeed = 8
    @balance = 1000
    @energy = 1000
  end

  def hurt_by(array)
    array.reject! do |bullet|
      if Gosu::distance(@x, @y - @image.height, bullet.x+bullet.width/2, bullet.y+bullet.height) < 10 then @energy -= bullet.pow ;end
      Gosu::distance(@x, @y - @image.height, bullet.x+bullet.width/2, bullet.y+bullet.height) < 10
    end
  end
  def warp (x, y)
    @x = x
    @y = y
  end
  def move_left;                self.warp(@x-10, @y); end
  def move_right;           self.warp(@x+10, @y); end
  def move_up ;                self.warp(@x, @y-10); end
  def move_down;                self.warp(@x, @y+10); end
  def draw;                     @image.draw_rot(@x, @y, 1, @angle); end
  def drawHit;                  @dmg.draw(@x, @y-10,2);end
  def shootSpeed ;           @shootSpeed ; end
  def increaseShootSpeed; if@shootSpeed >2; @shootSpeed-=1; end; end
  def decreaseShootSpeed; if @shootSpeed < 20 ; @shootSpeed+=1 ; end ; end
  def balance_down( x );      @balance-=x; end
  def current_balance;     @current_balance;end
  def width ;                @image.width;end
end
class Bullet
  attr_reader :x, :y, :pow
  attr_accessor :recoil
  def initialize(window ,x, y)
    @bullet = Gosu::Image.new(window, "img/JellyGreen.png", false)
    @pow = 2
    @recoil = 20
    @x ,@y = x,y
    @axx = @x + @bullet.width/2
    @axy = @y + @bullet.height/2
  end
  def draw;                    @bullet.draw @x,@y-=30,0 ;end
  def width ;                         @bullet.width ;end
  def height ;                         @bullet.height ;end

end

class BulletM <Bullet
  def initialize(window ,x, y)
    super
    @bullet = Gosu::Image.new(window, "img/JellyBlueM.png", false)
    @pow = 8
    @recoil = 40
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
  def draw;                     @bullet.draw @x,@y +=10, 0 ;end
end

class AssaultBullet1<Bullet

  def initialize(window ,x, y)
    super
    @bullet = Gosu::Image.new(window,"img/AssaultBullet1.png")
    @pow = 5
    @speed = 40
  end
  def draw;                    @bullet.draw @x,@y+=10,0 ;end
end
class AssaultBullet2<Bullet
  def initialize(window ,x, y)
    super
    @bullet = Gosu::Image.new(window,"img/AssaultBullet2.png")
    @pow = 5
    @speed = 40
  end
  def draw;                    @bullet.draw @x,@y+=10,0 ;end
end
class CruiserBullet1<Bullet
  def initialize(window ,x, y)
    super
    @bullet = Gosu::Image.new(window,"img/CruiserBullet1.png")
    @pow = 5
    @speed = 40
  end
  def draw;                    @bullet.draw @x,@y+=10,0 ;end
end
class CruiserBullet2<Bullet
  def initialize(window ,x, y)
    super
    @bullet = Gosu::Image.new(window,"img/CruiserBullet2.png")
    @pow = 5
    @speed = 40
  end
  def draw;                    @bullet.draw @x,@y+=10,0 ;end
end
class Enemy
  attr_reader :x, :y
  attr_accessor :energy
  attr_accessor :shootSpeed
  def initialize(window, x, y)
    @x = x
    @y = y
    @max_energy = 10
    @moveSpeed = 1
    @energy = @max_energy
    @shootSpeed = 10
    @image = Gosu::Image.new(window,"img/Enemy1.png")
  end
  def hurt_by(array)
    array.reject! do |bullet|
      if (((self.x+self.width/2)- (bullet.x+bullet.width/2)).abs < self.width) && (((self.y+self.height/2)- (bullet.y+bullet.height/2)).abs < self.height)
        self.hit(bullet.pow,bullet.recoil);
        true;
      end
    end
  end
  def draw(x, y);                      @image.draw(x, y,0); end
  def move (x,y);                      @x= x; @y = y;end      #@y  += (Math.sin(Gosu::milliseconds / 133.7))+@moveSpeed;end
  def energy ;                         @energy; end
  def hit (pow, recoil) ;              @energy -= pow ;end
  def height;                          @image.height; end
  def width;                           @image.width; end
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
    @shootSpeed = 5
    @image = Gosu::Image.new(window,"img/Enemy2.png")
  end
  # def move (x,y);           @x= x; @y = y + @moveSpeed; end
  def move (x,y)
    @x + ((50)- @image.width) + (Math.sin(Gosu::milliseconds / 133.7) * ((50) - @image.width))
    @y =  y += 1
  end
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
    @shootSpeed =5
    @image = Gosu::Image.new(window,"img/Enemy3.png")
    @windowWidth = window.width
  end
  def move (x,y)
    @x = ((@windowWidth/2)- @image.width) + (Math.sin(Gosu::milliseconds / 1333.7)*((@windowWidth/2)- @image.width))
    @y =  y += 1
  end
  def shoot (window)
    CruiserBullet2.new(window,@x+@image.width/2, @y+@image.height)
  end
end

######################################    Init of Window And Gosu Magicks
window = GameWindow.new
window.show
