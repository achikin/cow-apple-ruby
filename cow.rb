require 'gosu'
class Obj
  def initialize(pos, image, z)
    @pos = pos
    @image = image
    @z = z
  end
  def intersect(object) (object.xmin < xmax and xmin < object.xmax) end
  def xmin() @pos[0] end
  def xmax() @image.width + @pos[0] end
  def draw() @image.draw(*@pos, @z) end
  def width() @image.width end
end

class Cow < Obj
  def initialize(pos, image_left, image_right,z)
    super pos, image_left, z
    @image_right = image_right
    @dir = :left
  end
  def draw
   @image.draw(*@pos, @z) if @dir == :left
   @image_right.draw(*@pos, @z) if @dir == :right
  end
  def xmin() @pos[0] + 70 end
  def backx() @dir==:left ? xmax : xmin end
  def xmax() @image.width + @pos[0] - 70 end
  def move(x)
    @dir = :right if x > 0 and @dir == :left
    @dir = :left if x < 0 and @dir == :right
    @pos[0] = [0, @pos[0] + x, 1200-@image.width].sort[1] #clamp
  end
end

class Window < Gosu::Window
  def floor
    450
  end
  def initialize
    super 1200, 600, false
    self.caption = "Cow and apples"
    @bg = Gosu::Image.new(self, 'orchard.png', true)
    @cow = Cow.new([600,300],Gosu::Image.new(self, 'cow.png', true), Gosu::Image.new(self, 'woc.png', true), 2)
    @apple_img = Gosu::Image.new(self, 'apple.png', true)
    @poo_img = Gosu::Image.new(self,'poo.png', true)
    @apples = []
    @poos = []
    @good_old_time = 0
    @font = Gosu::Font.new(self, Gosu::default_font_name, 40)
    @score = 0
    @last_time = 0
  end

  def spawn_apple
    x = rand(0..1200-@cow.width-@apple_img.width)
    x = x + @cow.width if x > @cow.xmin #dont spawn apples on cow
    @apples << Obj.new([x, floor], @apple_img, 2)
  end

  def update
    ms = Gosu::milliseconds
    delta = ms - @last_time
    @last_time = ms
    @cow.move(-0.3*delta) if button_down? Gosu::KbLeft or button_down? Gosu::GpLeft
    @cow.move(0.3*delta) if button_down? Gosu::KbRight or button_down? Gosu::GpRight
    if (ms - @good_old_time) > 2000#2s
      @good_old_time = ms
      spawn_apple
    end
    @apples.reject! do |apple| 
      res = apple.intersect @cow
      if res
        @score = @score + 1 if res
        if @score%10 == 0
          @poos << Obj.new([@cow.backx, 500], @poo_img, 1)
        end
      end
      res
    end

  end

  def draw
    @bg.draw(0,0,0)
    @cow.draw
    @apples.each{|apple| apple.draw}
    @poos.each{|poo| poo.draw}
    @font.draw("Score: #{@score}", 10, 10, 3, 1.0, 1.0, 0xffffff00)
  end
end

window = Window.new
window.show
