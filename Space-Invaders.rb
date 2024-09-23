require 'gosu'

class Ship
    attr_reader :x, :y, :width

    def initialize(window)
        @image = Gosu::Image.new("img/ship.png")
        @bullet = Gosu::Image.new("img/bullet.png")
        @sound = Gosu::Sample.new("sound/pew.mp3")
        @x = (window.width - @image.width) / 2
        @y = window.height - window.height * 0.1
        @vel_x = 7
        @vel_bullet = 50
    end

    def update(window)
        if window.button_down?(Gosu::KB_A)
            @x -= @vel_x
        end
        if window.button_down?(Gosu::KB_D)
            @x += @vel_x
        end
    end

    def draw
        @image.draw(@x, @y, 1)
    end
end

class Bullet
    def initialize(ship)
        @image = Gosu::Image.new("img/bullet.png")
        @x = ship.x
        @y = ship.y

    end

    def update
        @y -= 20
    end

    def draw
        @image.draw(@x, @y, 0)
    end

end

class Game < Gosu::Window
    #Konstruktor
    def initialize
        super 1600, 1000
        self.caption = "Space Invaders"
        @ship = Ship.new(self)
        @bullets = []
    
    end

    def update
        @ship.update(self)
        if button_down?(Gosu::KB_SPACE)
            @bullets << Bullet.new(@ship)
            
        end
        @bullets.each { |bullet| bullet.update}
    end

    def draw
        @ship.draw
        @bullets.each { |bullet| bullet.draw }
    end
end

game = Game.new
game.show