# Code that only gets run once on game start
def init(args)
  reset_swipe(args)
  GameSetting.load_settings(args)
  args.state.scene_switch_tick ||= 0
  # args.outputs.static_primitives << Layout.debug_primitives
end

def tick(args)
  init(args) if args.state.tick_count.zero?

  # this looks good on non 16:9 resolutions; game background is different
  args.outputs.background_color = TRUE_BLACK.values

  args.state.has_focus ||= true
  args.state.scene ||= :skill_tree

  track_swipe(args) if mobile?

  Scene.send("tick_#{args.state.scene}", args)

  debug_tick(args)
rescue FinishTick # rubocop:disable Lint/SuppressedException
end

# raise this as an easy way to end the current tick early
class FinishTick < StandardError; end

# code that only runs while developing
# put shortcuts and helpful info here
def debug_tick(args)
  return unless debug?

  debug_label(
    args, 24.from_right, 24.from_top,
    "v#{version} | DR v#{$gtk.version} (#{$gtk.platform}) | Ticks: #{args.state.tick_count} | FPS: #{args.gtk.current_framerate.round}",
    ALIGN_RIGHT
  )

  debug_label(
    args, 24.from_right, 48.from_top,
    "mouse x: #{args.inputs.mouse.x}/y: #{args.inputs.mouse.y}",
    ALIGN_RIGHT
  )

  debug_label(
    args, 24.from_right, 72.from_top,
    "cursor x: #{args.state.cursor.x}/y: #{args.state.cursor.y}",
    ALIGN_RIGHT
  )

  debug_label(
    args, 24.from_right, 96.from_top,
    "camera scale: #{args.state.camera.scale}",
    ALIGN_RIGHT
  )

  if args.inputs.keyboard.key_down.kp_zero
    play_sfx(args, :select)
    args.state.render_debug_details = !args.state.render_debug_details
  end

  if args.inputs.keyboard.key_down.i
    play_sfx(args, :select)
    Sprite.reset_all(args)
    args.gtk.notify!('Sprites reloaded')
  end

  if args.inputs.keyboard.key_down.r
    play_sfx(args, :select)
    $gtk.reset
  end

  return unless args.inputs.keyboard.key_down.m

  play_sfx(args, :select)
  args.state.simulate_mobile = !args.state.simulate_mobile
  msg = if args.state.simulate_mobile
          'Mobile simulation on'
        else
          'Mobile simulation off'
        end
  args.gtk.notify!(msg)
end

# render a label that is only shown when in debug mode and the debug details
# are shown; toggle with +0+ key
def debug_label(args, x, y, text, align = ALIGN_LEFT)
  return unless debug?
  return unless args.state.render_debug_details

  args.outputs.debug << { x: x, y: y, text: text, alignment_enum: align }.merge(WHITE).label!
end

# different than background_color... use this to change the bg color for the
# visible portion of the game
def draw_bg(args, color)
  args.outputs.solids << { x: args.grid.left, y: args.grid.bottom, w: args.grid.w, h: args.grid.h }.merge(color)
end

# draw a background sprite that fills the screen
# bg_sprite should be a hash containing sprite primitive attributes (path, RGB, alpha, etc)
def draw_bg_sprite(args, bg_sprite)
  args.outputs.sprites << { x: args.grid.left, y: args.grid.bottom, w: args.grid.w, h: args.grid.h }.merge(bg_sprite)
end
