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
        @shot_cooldown = 0.5
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
        @image.draw(@x + 50, @y - @image.height / 2, 0)
    end
end

class EnemyBullet
    def initialize(x, y)
        @image = Gosu::Image.new("img/enemy_bullet.png")
        @x = x
        @y = y
        @speed = 5
    end

    def update
        @y += @speed
    end

    def draw
        @image.draw(@x, @y, 0)
    end
end

class Enemy
    attr_reader :x, :y

    def initialize(x, y)
        @x = x
        @y = y
        @image = Gosu::Image.new("img/alien.png")
        @shoot_cooldown = rand(3..10)
        @last_shot_time = Time.now
    end

    def shoot
        current_time = Time.now
        if current_time - @last_shot_time >= @shoot_cooldown
            @last_shot_time = current_time
            @shoot_cooldown = rand(2..5)
            return EnemyBullet.new(@x, @y)
        end
        return nil
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
        @enemy_bullets = []
        @last_shooter_time = Time.now
        @enemy_shoot_cooldown = 2

        spawn_enemies
    end

    def spawn_enemies
        6.times do |i|
            8.times do |n|
                x = (180 + 130 * n)
                y = (30 + 90 * i)
                @enemies << Enemy.new(x, y)
            end
        end
    end

    def front_enemies
        front_enemies = []
        @enemies.group_by { |enemy| enemy.x }.each_value do |column_enemies|
            front_enemy = column_enemies.max_by { |enemy| enemy.y }
            front_enemies << front_enemy if front_enemy
        end
        front_enemies
    end

    def update
        @ship.update(self)
    
        # Player shooting
        if button_down?(Gosu::KB_SPACE)
            bullet = @ship.shoot
            @bullets << bullet if bullet
        end
    
        # Update player bullets
        @bullets.each { |bullet| bullet.update }
    
        # Update enemy bullets
        @enemy_bullets.each { |enemy_bullet| enemy_bullet.update }
    
        # Only allow frontmost aliens to shoot
        current_time = Time.now
        if current_time - @last_shooter_time >= @enemy_shoot_cooldown
            # Get the list of frontmost enemies
            front_enemies_list = front_enemies
            
            # Pick one random front enemy to shoot
            shooting_enemy = front_enemies_list.sample
            enemy_bullet = shooting_enemy.shoot if shooting_enemy
            @enemy_bullets << enemy_bullet if enemy_bullet
            
            # Reset the time for the next shot and randomize the cooldown period
            @last_shooter_time = current_time
            @enemy_shoot_cooldown = rand(2..5)
        end
    
        # Update enemies and remove those hit by bullets
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
        @enemy_bullets.each { |enemy_bullet| enemy_bullet.draw }
        @enemies.each { |enemy| enemy.draw }
    end
end

game = Game.new
game.show
