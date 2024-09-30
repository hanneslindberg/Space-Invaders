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
        @last_shot_time = Time.now - 1
        @shot_cooldown = 0.3
    end

    def shoot
        current_time = Time.now
        if current_time - @last_shot_time >= @shot_cooldown 
            @last_shot_time = current_time
            @sound.play 
            return Bullet.new(self)  
        else
            return nil 
        end
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
    attr_reader :x, :y

    def initialize(ship)
        @image = Gosu::Image.new("img/bullet.png")
        @x = ship.x
        @y = ship.y

        @speed = 10
    end

    def update
        @y -= @speed
    end

    def draw
        @image.draw(@x - @image.width / 2, @y - @image.height / 2, 0)
    end
end

class Enemy
    attr_reader :x, :y

    def initialize(x, y)
        @x = x
        @y = y
        @image = Gosu::Image.new("img/alien.png")
    end

    def update
        
    end

    def draw
        @image.draw(@x - @image.width / 2, @y - @image.height / 2, 0)
    end
end

class Game < Gosu::Window
    def initialize
        super 1600, 1000
        self.caption = "Space Invaders"
        @game_start = false 

        @ship = Ship.new(self)
        @bullets = []
        @enemies = []

        spawn_enemies
    end

    def spawn_enemies
        6.times do |i|
            8.times do |n|
                x = (340 + 120 * n)
                y = (40 + 80 * i)

                @enemies << Enemy.new(x, y)
            end
        end
    end

    def update

        @ship.update(self)

        if button_down?(Gosu::KB_SPACE) 
            bullet = @ship.shoot
            @bullets << bullet if bullet 
        end

        @bullets.each(&:update)

        @enemies.each(&:update)

        @enemies.reject! do |enemy|
            @bullets.any? do |bullet|
                if collision?(bullet, enemy)
                    @bullets.delete(bullet) 
                    true 
                end
            end
        end
    end

    def collision?(a, b)
        distance = Gosu.distance(a.x, a.y, b.x, b.y)
        distance < 50

    end

    def draw
        @ship.draw
        @bullets.each { |bullet| bullet.draw }
        @enemies.each { |enemy| enemy.draw }
    end
end

game = Game.new
game.show
