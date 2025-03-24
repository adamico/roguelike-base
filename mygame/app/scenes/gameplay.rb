module Scene
  class << self
    # This is your main entrypoint into the actual fun part of your game!
    def tick_gameplay(args)
      labels = []
      sprites = []

      # focus tracking
      if !args.state.has_focus && args.inputs.keyboard.has_focus
        args.state.has_focus = true
      elsif args.state.has_focus && !args.inputs.keyboard.has_focus
        args.state.has_focus = false
      end

      # auto-pause & input-based pause
      return pause(args) if !args.state.has_focus || pause_down?(args)

      tick_pause_button(args, sprites) if mobile?

      draw_bg(args, BLACK)

      labels << label('GAMEPLAY', x: 40, y: args.grid.top - 40, size: SIZE_LG, font: FONT_BOLD)
      args.outputs.labels << labels
      args.outputs.sprites << sprites
    end

    def pause(args)
      play_sfx(args, :select)
      Scene.switch(args, :paused, reset: true)
    end

    def tick_pause_button(args, sprites)
      pause_button = {
        x: 72.from_right,
        y: 72.from_top,
        w: 52,
        h: 52,
        path: Sprite.for(:pause)
      }
      pause_rect = pause_button.dup
      pause_padding = 12
      pause_rect.x -= pause_padding
      pause_rect.y -= pause_padding
      pause_rect.w += pause_padding * 2
      pause_rect.h += pause_padding * 2
      return pause(args) if args.inputs.mouse.down && args.inputs.mouse.inside_rect?(pause_rect)

      sprites << pause_button
    end
  end
end
