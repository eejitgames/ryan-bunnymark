class Bunny
  def initialize mouse
    @x    = mouse.x - 256 / 3 / 2
    @y    = mouse.y
    @w    = 256 / 3
    @h    = 218 / 3
    @path = 'sprites/ryan-bunny.png'
    @g    = -0.2
    @vx   = rand * 6 - 3
    @vy   = rand * 12 - 6
    @sw   = 1280
    @sh   = 720
    @num  = 0
  end

  def draw_override ffi_draw
    @x += @vx
    @y += @vy
    @vy += @g

    if @x < 0
      @x = 0
      @vx *= -1
    elsif @x + @w > @sw
      @x = @sw - @w
      @vx *= -1
    end

    if @y < 0
      @y = 0
      @vy *= -0.98
    end
    ffi_draw.draw_sprite @x, @y, @w, @h, @path
  end
end

class FpsLabel
  attr :args

  def initialize txt
    @x              = 270
    @y              = 710
    @text           = txt
    @size_enum      = 5
    @alignment_enum = 0
    @r              = 0
    @g              = 0
    @b              = 0
    @a              = 255
    @font           = "fonts/font.ttf"
  end

  def draw_override ffi_draw
    fps = args.gtk.current_framerate.round
    sim = args.gtk.current_framerate_calc.round
    rnd = args.gtk.current_framerate_render.round
    num = args.state.bunny_count
    @text = "fps: #{fps} simulation: #{sim} render: #{rnd} bunnies: #{num}"
    ffi_draw.draw_label @x, @y, @text, @size_enum, @alignment_enum, @r, @g, @b, @a, @font
  end
end

def tick args
  args.outputs.background_color = [ 0x40, 0xd6, 0x62 ] # ~ midway between the greens 3bd662 and 45a55d

  if args.state.tick_count == 0
    args.state.bunny_count = 0
    args.state.spawn_batch = 100
    args.outputs.static_sprites << {
      x: 0,
      y: 0,
      w: 1280,
      h: 720,
      path: 'sprites/grass_background.png'
    }
    txt = ''
    $fps_label ||= FpsLabel.new txt
    $fps_label.args = args
    args.outputs.static_labels << args.state.spawn_batch.map { |i| $fps_label }
  end

  if args.inputs.mouse.click
    args.state.bunny_count += args.state.spawn_batch
    args.outputs.static_sprites << args.state.spawn_batch.map { |i| Bunny.new args.inputs.mouse }
  end
end
