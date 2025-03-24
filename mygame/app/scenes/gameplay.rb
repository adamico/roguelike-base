module Scene
  class << self
    # This is your main entrypoint into the actual fun part of your game!
    def tick_gameplay(args)
      labels = []
      setup

      handle_focus

      # auto-pause & input-based pause
      return pause if !args.state.has_focus || pause_down?(args)

      tick_pause_button(sprites) if mobile?

      player_action = player_action(process_inputs)
      game.perform_player_action(player_action) if player_action

      render(labels)
    end

    def setup
      state.entity_store ||= EntityStore.new(
        component_definitions: default_component_definitions
      )

      setup_tilemap
      setup_game
      setup_map
    end

    def setup_game
      state.game ||= Game.new(entity_store: state.entity_store)
      game.player_entity ||= game.create_entity(:player, x: 20, y: 12)
    end

    def setup_map
      state.map ||= game.create_entity(:map, cells: Array.new(40) { Array.new(23) })
      state.map_renderer ||= MapRenderer.new(
        tilemap: tilemap,
        entity_store: game.entity_store,
        tileset: tileset
      )
    end

    def setup_tilemap
      state.tilemap_size ||= { w: 80, h: 45 }
      state.tileset ||= build_tileset
      state.tilemap ||= Tilemap.new(
        x: 0, y: 0,
        cell_w: 32, cell_h: 32,
        grid_w: tilemap_size[:w], grid_h: tilemap_size[:h],
        tileset: tileset
      )
    end

    def handle_focus
      # focus tracking
      if !state.has_focus && args.inputs.keyboard.has_focus
        state.has_focus = true
      elsif state.has_focus && !args.inputs.keyboard.has_focus
        state.has_focus = false
      end
    end

    def render(labels)
      draw_bg(args, BLACK)

      render_ui(labels)

      map_renderer.render(game.current_map, offset_x: 0, offset_y: 0)
      args.outputs.primitives << sprites
    end

    def render_ui(labels)
      #labels << label('GAMEPLAY', x: 40, y: args.grid.top - 40, size: SIZE_LG, font: FONT_BOLD)
      args.outputs.labels << labels
    end

    def pause
      play_sfx(args, :select)
      Scene.switch(args, :paused, reset: true)
    end

    def tick_pause_button(sprites)
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

    def process_inputs
      key_down = args.inputs.keyboard.key_down
      input_actions = {}
      if key_down.left
        input_actions[:move] = { x: -1, y: 0 }
      elsif key_down.right
        input_actions[:move] = { x: 1, y: 0 }
      elsif key_down.down
        input_actions[:move] = { x: 0, y: -1 }
      elsif key_down.up
        input_actions[:move] = { x: 0, y: 1 }
      end
      input_actions
    end

    def game
      state.game
    end

    def map
      state.map
    end

    def map_renderer
      state.map_renderer
    end

    def sprites
      map_renderer.sprites
    end

    def tilemap
      state.tilemap
    end

    def tilemap_size
      state.tilemap_size
    end

    def tileset
      state.tileset
    end

    def args
      $gtk.args
    end

    def state
      args.state
    end

    private

    def player_action(input_actions)
      return unless input_actions[:move]

      { type: :move, x: input_actions[:move][:x], y: input_actions[:move][:y] }
    end
  end
end
