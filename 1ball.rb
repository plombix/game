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
    @seed= [] ; while @seed.count< 27 ; @seed<<rand(1..30)*15; end;
    @bulletrain = []
    @bulletfall = []
    @bulletchain = []
    @badguy =  []
    @goodguy =  []
    @hardguy= []
    @phase =  0
    @frame = 0
    @totaltime = 0
    @arc = 0
    @skrolIndex = 0
    @total_balance = 0
    @balance_max = 1000.0
    @gameState = 0          # 0 = Start menu  1 = Game in progress  2 = Game in pause  3 = Game in end of day 4 = Game in mana
    #############Sounds
    @wait_a_min = Gosu::Sample.new(self, "sound/wait-a-minute.wav")
    @pew = Gosu::Sample.new(self, "sound/pew1.wav")
    #############Texts
    self.caption = "_-{]   BalanceD   [}-_"
    @start_text1 = Gosu::Image.from_text(self,"_-{]  Entree pour Commencer  [}-_", "font/simple.ttf",  55)
    @start_text2 = Gosu::Image.from_text(self,"_-{]    Escape pour Quitter    [}-_", "font/simple.ttf",  55)
    @continue = Gosu::Image.from_text(self,"_-{]  Entree pour Continuer  [}-_", "font/simple.ttf",  55)
    @quit= Gosu::Image.from_text(self,"_-{]  P pour Quitter  [}-_", "font/simple.ttf",  55)
    # @count2 = Gosu::Image.from_text(self,"_-{]  2  [}-_", "font/simple.ttf",  55)
    # @count1 = Gosu::Image.from_text(self,"_-{]  1  [}-_", "font/simple.ttf",  55)
    # @count0 = Gosu::Image.from_text(self,"_-{]  GO!  [}-_", "font/simple.ttf",  55)
    #############Images/Anims
    @dayEnd = Gosu::Font.new(self, "font/simple.ttf",  45)
    @dayEndtitle = Gosu::Font.new(self, "font/simple.ttf",  60)
    @bankMessage = Gosu::Font.new(self, "font/simple2.TTF", 30)
    @balance = Gosu::Font.new(self, "font/simple.ttf",  45)
    @totalBalance = Gosu::Font.new(self, "font/simple.ttf",  45)
    @current_balance = Gosu::Font.new(self, "font/simple.ttf",  70)
    @current_energy = Gosu::Font.new(self, "font/simple.ttf",  70)
    @background_image = Gosu::Image.new(self, "img/bg_starVII.png", false)
    @starscroll = Gosu::Image.new(self,"img/StarFar.png", false)
    @redgreen = Gosu::Image.new(self,"img/redgreen.png", false)
    @needle = Gosu::Image.new(self,"img/needle.png", false)
    # @starscrollsp = Gosu::Image.new(self,"img/Starclose.png", false)
    @startBackground = Gosu::Image.new(self, "img/Title.png", false)
    @damageFire = Gosu::Image.load_tiles(self, "img/SpriteHit.png", 96,96, false)
    @shop = Gosu::Image.new(self, "img/ShopFonf2.png", false)
    @preshop = Gosu::Image.new(self, "img/ShopFonf.png", false)
    @iconShield = Gosu::Image.new(self, "img/Shieldbutton.png",false)
    @iconInvest = Gosu::Image.new(self, "img/UpgradeButton.png",false)
    @iconLoan = Gosu::Image.new(self, "img/HandButton.png",false)
    @pointer = Gosu::Image.new(self, "img/pointer.png",false)
    @dmg2 = Gosu::Image.new(self,"img/dmg.png", false)
    @dead = Gosu::Image.new(self,"img/Dead.png",false)
    #############Entity
    @player = Player.new(self)
    @badguy<< Fighter.new(self ,self.width/6,@seed[0])<< Fighter.new(self , (width/6)*2,@seed[1])<< Fighter.new(self , (width/6)*3,@seed[2])<< Fighter.new(self , (width/6)*4,@seed[3])<< Fighter.new(self , (width/6)*5,@seed[4])
    @seed.rotate(@badguy.size)
  end

  def up_frame ;@frame +=1 ;@skrolIndex +=10 ;if @skrolIndex >= 0 then @skrolIndex = -@starscroll.height+1024 end ;end
  def frameReset; @frame = 0; end
  def frame; @frame; end
  def button_up? (id); if button_up(id) ; true;end;end
  def update
    self.up_frame
    if @gameState == 0                                                 # 0 = Start menu
      @player.energy = 500
      if button_down? Gosu::KbReturn; @gameState = 1; elsif button_down? Gosu::KbEscape; close; end
      if button_down? Gosu::MsLeft ;sleep(0.5);@gameState = 1;end
    elsif @gameState == 1                                              # 1 = Game in progress
      ####################################### Basic movement an shooting states update
      @totaltime += 1
      if @player.energy < 0 ;@gameState = 6;end
      if button_down? Gosu::KbEscape ;@gameState = 2 ;self.frameReset ;end
      @player.warp(mouse_x, mouse_y)
      if (@player.hurt_by(@bulletfall) == true)
        @arc = 30;
      end
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
      if (@goodguy)
        @goodguy.each do |b|
          b.hurt_by(@bulletfall)
          b.move(b.x, b.y);
          if@frame % b.shootSpeed == 0
            @bulletrain<<b.shoot(self)
          end
        end
      end
      ######################################## Controlling game state by ennemy presence && setup of squads
      if @badguy.empty?
        @phase +=1
        if @phase == 1
          @badguy << Assault.new(self ,self.width/6,@seed[0])<< Assault.new(self , (width/6)*2,@seed[1])<< Assault.new(self , (width/6)*3,@seed[2])<< Assault.new(self , (width/6)*4,@seed[3])<< Assault.new(self , (width/6)*5,@seed[4])
          @seed.rotate(@badguy.size)
        elsif @phase == 2
          @badguy  << Assault.new(self ,self.width/6,@seed[0])<< Fighter.new(self , (width/6)*2,@seed[1])<< Cruiser.new(self , (width/6)*3,@seed[2])<< Fighter.new(self , (width/6)*4,@seed[3])<< Assault.new(self , (width/6)*5,@seed[4])
          @seed.rotate(@badguy.size)
        elsif @phase == 3
          @badguy << Fighter.new(self ,self.width/6,@seed[0] +70)<< Fighter.new(self , (width/6)*2,@seed[1] +70)<< Fighter.new(self , (width/6)*3,@seed[2] +70)<< Fighter.new(self , (width/6)*4,@seed[3] +70)<< Fighter.new(self , (width/6)*5,@seed[4] +70)<< Assault.new(self ,self.width/6,@seed[0])<< Fighter.new(self , (width/6)*2,@seed[1])<< Cruiser.new(self , (width/6)*3,@seed[2])<< Fighter.new(self , (width/6)*4,@seed[3])<< Assault.new(self , (width/6)*5,@seed[4])
          @seed.rotate(@badguy.size)
        elsif @phase == 4
          @gameState = 3
        end
      end
    elsif @gameState == 2                                         # 2 = Game in pause
      if button_down? Gosu::KbReturn ;sleep(0.5);@gameState = 1 ;elsif button_down? Gosu::KbP ;close ;end
      if button_down? Gosu::MsLeft ;sleep(0.5);@gameState = 1;end
    elsif  @gameState == 3
      puts @gameState
      @day+=1
      @total_balance += @player.balance/10
      @gameState = 4
    elsif @gameState == 4
      if button_down? Gosu::KbReturn ;sleep(0.5);@gameState = 5;end
      if button_down? Gosu::MsLeft ;sleep(0.5);@gameState = 5;end
    elsif @gameState == 5
      if button_down? Gosu::KbReturn; @gameState = 1;end
      if @total_balance > 0
        if button_down? Gosu::MsLeft
          if mouse_x <400 && mouse_x > 300 && mouse_y <400 && mouse_y > 300
            @player.shield += 50
            @total_balance -= 40
            sleep(0.5)
          elsif mouse_x <400 && mouse_x > 300 && mouse_y <510 && mouse_y >  410
            @player.ally += 1
            @goodguy << Ally.new(self, self.width/2, self.height - 10)
            @total_balance -= 100
            sleep(0.5)
          elsif mouse_x <400 && mouse_x > 300 && mouse_y <620 && mouse_y > 520
            @player.loan += 1
            @total_balance +=700
            @player.daypay -= 300
            sleep(0.5)
          end
        end
      elsif @total_balance <= 0
        if button_down? Gosu::MsLeft
          if mouse_x <400 && mouse_x > 300 && mouse_y <400 && mouse_y > 300
            @player.shield += 50
            @total_balance -= 40
            sleep(0.5)
          elsif mouse_x <400 && mouse_x > 300 && mouse_y <510 && mouse_y >  410
            @player.ally += 100
            @goodguy << Ally.new(self, self.width/2, self.height - 50)
            @total_balance -= 30
            sleep(0.5)
          elsif mouse_x <400 && mouse_x > 300 && mouse_y <620 && mouse_y > 520
            @player.loan += 1
            @total_balance +=700
            @player.daypay -= 200
            sleep(0.5)
          end
        end
      end
      if button_down? Gosu::KbReturn
        @day +=1
        @player.balance = ( 1000 - @player.loan * 200)
        @bulletrain = []
        @phase = 0

        @badguy<< Fighter.new(self ,self.width/6,@seed[0])<< Fighter.new(self , (width/6)*2,@seed[1])<< Fighter.new(self , (width/6)*3,@seed[2])<< Fighter.new(self , (width/6)*4,@seed[3])<< Fighter.new(self , (width/6)*5,@seed[4])
        @gameState = 1

      end
    elsif @gameState == 6
      if button_down? Gosu::KbReturn;sleep(0.5); @gameState = 0; elsif button_down? Gosu::KbEscape; close;end
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
      if (@goodguy)
        @goodguy.each do |g|
          g.draw(g.x,g.y);
        end
      end
      if @badguy
        @badguy.each do |x|
          x.damaged.each do |d|
            if (d < -x.width / 2)
              d = -x.width / 2
            elsif d > x.width / 2
              d = x.width / 2
            end
            @damageFire[(@totaltime % 8)].draw(x.x + d, x.y, 0)
          end
        end
      end
      if (@arc > 0)
        @arc -= 1;
        puts @arc;
        @dmg2.draw(@player.x - 50, @player.y - (40 + 10), 2);
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
      angle = (@total_balance * -45.0) / @balance_max;
      @redgreen.draw(0, self.height - @redgreen.height,10);
      @needle.draw_rot(10, self.height - 10, 10, angle + 45.0, 0.5, 1);
    elsif @gameState == 2                                              # 2 = Game in pause
      @background_image.draw_as_quad(0, 0, 0xeeeeeee, self.width, 0, 0xeeeeeee, self.width, self.height, 0xeeeeeee, 0, self.height, 0xeeeeeee, 0)
      @continue.draw width/2- @continue.width/2 , height/2- @continue.height/2, 1
      @quit.draw width/2- @quit.width/2 , height/2- @quit.height/2 + @quit.height, 1
    elsif @gameState == 4
      @preshop.draw(0,0,0)
      @dayEndtitle.draw(           " Bataille _-| #{@day} |-_ est finie !",450,100,1 )
      @balance.draw(          "Ta reserve de balle est :    #{@player.balance}",550, 500,1)
      @totalBalance.draw(    "Ton solde est :              #{@total_balance}",550,550,1)
      @continue.draw(450,900,1)
    elsif @gameState == 5
      @shop.draw(0,0,0)
      @pointer.draw(mouse_x, mouse_y,3)
      if @total_balance > 0
        @bankMessage.draw("Hum ... Vous avez des DISPONIBILITES." , 1000,600,1,1,1,Gosu::Color::BLACK)
        @bankMessage.draw("Peut etre pouvons nous vous PROPOSER" , 1000,650,1,1,1,Gosu::Color::BLACK)
        @bankMessage.draw("des AMELIORATIONS " , 1000,710,1,1,1,Gosu::Color::BLACK)
        @iconShield.draw(300,300,2)
        @bankMessage.draw("#{@player.shield}", 500,300,1,1,1,Gosu::Color::BLACK)
        @iconInvest.draw(300,410,2)
        @bankMessage.draw("#{@player.ally}", 500,410,1,1,1,Gosu::Color::BLACK)
        @iconLoan.draw(300,520,2)
        @bankMessage.draw("#{@total_balance}", 500,520,1,1,1,Gosu::Color::BLACK)
        @start_text1.draw width/2 - @start_text1.width/2, height- 170, 10
      elsif @total_balance < 0
        @bankMessage.draw("Hum ... Vous etes a DECOUVERT." , 1000,600,1,1,1,Gosu::Color::BLACK)
        @bankMessage.draw("Les prochains jours riquent d'etre DURS", 1000,655,1,1,1,Gosu::Color::BLACK)
        @bankMessage.draw("Nous pensons pouvoir vous AIDER " , 1000,710,1,1,1,Gosu::Color::BLACK)
        @iconShield.draw(300,300,2)
        @bankMessage.draw("#{@player.shield}", 500,300,1,1,1,Gosu::Color::BLACK)
        @iconInvest.draw(300,410,2)
        @bankMessage.draw("#{@player.ally}", 500,410,1,1,1,Gosu::Color::BLACK)
        @iconLoan.draw(300,520,2)
        @bankMessage.draw("#{@total_balance}", 500,520,1,1,1,Gosu::Color::BLACK)
        @continue.draw 50, height- 170, 10
      end
    elsif @gameState == 6
      @dead.draw(0,0,0)
      @start_text1.draw width/2 - @start_text1.width/2, height- 170, 10
      @start_text2.draw width/2 - @start_text2.width/2, height- 100, 10
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
  attr_accessor :balance ,:x, :y, :energy , :ally , :loan,:shield , :daypay
  attr_reader :axx ,:axy
  def initialize (window)
    @dmg = Gosu::Image.new(window,"img/dmg.png", false)
    @image = Gosu::Image.new(window, "img/StarshipHbox.png" ,false);
    @shieldImage = Gosu::Image.new(window, "img/shield.png" ,false);
    @axy = @axx = @x = @y = @vel_x = @vel_y = @angle =0.0
    @score = 0
    @shootSpeed = 8
    @daypay = 1000
    @balance = 1000
    @energy = 500
    @shield = 0
    @loan = 0
    @ally = 0
  end

  def hurt_by(array)
    @a = false
    array.reject! do |bullet|
      if Gosu::distance(@x, @y - @image.height, bullet.x+bullet.width/2, bullet.y+bullet.height) < 10
        if self.shield > 0
          self.shield-= bullet.pow
        else
          @energy -= bullet.pow;
        end
        @a = true;
      end
      Gosu::distance(@x, @y - @image.height, bullet.x+bullet.width/2, bullet.y+bullet.height) < 10
    end
    return @a;
  end
  def warp (x, y)
    @x = x
    @y = y
  end
  def move_left;                self.warp(@x-10, @y); end
  def move_right;           self.warp(@x+10, @y); end
  def move_up ;                self.warp(@x, @y-10); end
  def move_down;                self.warp(@x, @y+10); end
  def draw;
    @image.draw_rot(@x, @y, 1, @angle)
    if self.shield > 0
      @shieldImage.draw_rot(@x, @y, 1, @angle)
    end
  end
  def drawHit(x ,y);                  @dmg.draw(x, y);end
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
  attr_accessor :damaged, :total_balance
  def initialize(window, x, y)
    @total_balance = 1
    @x = x
    @y = y
    @max_energy = 10
    @moveSpeed = 1
    @energy = @max_energy
    @shootSpeed = 10
    @image = Gosu::Image.new(window,"img/Enemy1.png")
    @damaged = Array.new
  end
  def hurt_by(array)
    array.reject! do |bullet|
      #        if (((self.x+self.width/2)- (bullet.x+bullet.width/2)).abs < self.width) && ( self.y+self.height/2 - bullet.y) >= self.y
      if (((self.x+self.width/2)- (bullet.x+bullet.width/2)).abs < self.width) && (((self.y+self.height/2)- (bullet.y+bullet.height/2)).abs < self.height)
        self.hit(bullet.pow,bullet.recoil);
        @damaged.push(bullet.x - self.x)
        true;
      end
    end
  end
  def draw(x, y);                      @image.draw(x, y,0); end
  def move (x,y)
    if @total_balance < 0 && @frame%20 == 0
      @x = rand(50..(self.width-50))
      @y = rand(50..(self.height-50))
    else
      @x= x
      @y = y
    end
  end      #@y  += (Math.sin(Gosu::milliseconds / 133.7))+@moveSpeed;end
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
    @shootSpeed = 8
    @image = Gosu::Image.new(window,"img/Enemy2.png")
  end
  # def move (x,y);           @x= x; @y = y + @moveSpeed; end
  def move (x,y)
    if @total_balance < 0 && @frame%20 == 0
      @x = rand(50..(self.width-50))
      @y = rand(50..(self.height-50))
    else
      @x =  x + (Math.sin(Gosu::milliseconds / 133.7) * ((50) - @image.width))
      @y =  y += 1
    end
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
    if @total_balance < 0 && @frame%20 == 0
      @x = rand(50..(self.width-50))
      @y = rand(50..(self.height-50))
    else
      @x = ((@windowWidth/2)- @image.width) + (Math.sin(Gosu::milliseconds / 1333.7)*((@windowWidth/2)- @image.width))
      @y =  y += 1
    end
  end
  def shoot (window)
    CruiserBullet1.new(window,@x+@image.width/2, @y+@image.height)
  end
end
class Ally
  attr_reader :x, :y
  attr_accessor :energy
  attr_accessor :shootSpeed
  attr_accessor :damaged
  def initialize(window, x, y)
    @x = x
    @y = y
    @max_energy = 100
    @moveSpeed = 0.2
    @energy = @max_energy
    @shootSpeed = 35
    @image = Gosu::Image.new(window,"img/Ially.png")
    @damaged = Array.new
    @windowWidth = window.width
    @window = window
  end
  def hurt_by(array)
    array.reject! do |bullet|
      if (((self.x+self.width/2)- (bullet.x+bullet.width/2)).abs < self.width) && (((self.y+self.height/2)- (bullet.y+bullet.height/2)).abs < self.height)
        self.hit(bullet.pow,bullet.recoil);
        @damaged.push (bullet.x - self.x)
        true;
      end
    end
  end
  def draw(x, y);                      @image.draw(x, y,0); end
  def energy ;                         @energy; end
  def hit (pow, recoil) ;              @energy -= pow ;end
  def height;                          @image.height; end
  def width;                           @image.width; end
  def move (x,y)
    @x = ((@windowWidth/2)- @image.width) + (Math.sin(Gosu::milliseconds / 1333.7)*((@windowWidth/2)- @image.width))
  end
  def shoot (window)
    Bullet.new(@window ,@x-12, (@y-20))
  end
end

######################################    Init of Window And Gosu Magicks
window = GameWindow.new
window.show
