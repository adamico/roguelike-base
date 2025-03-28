Origin = Struct.new(:x, :y)

module Scene
  class << self
    def tick_skill_tree(_args)
      setup
      render
      move_cursor
      move_with_mouse
      handle_zoom
    end

    def setup
      setup_world
      setup_tree
    end

    def setup_world
      args.state.world ||= { w: 1280, h: 720 }
      args.state.camera ||= { x: 640, y: 300, scale: 1.0 }
      args.state.cursor ||= { x: 640, y: 300, size: 32 }
    end

    def setup_tree
      state.graphic_nodes = []
      state.lines = []

      origin = Origin.new(11, 5)

      state.tree = Tree.new(
        [
          { color: 'white', x: origin.x, y: origin.y, links: [1, 3, 4] },         # 0
          { color: 'orange', x: origin.x - 1, y: origin.y - 1, links: [0, 2] },   # 1
          { color: 'violet', x: origin.x - 1, y: origin.y - 2, links: [1] },      # 2
          { color: 'blue', x: origin.x, y: origin.y - 1, links: [0] },            # 3
          { color: 'red', x: origin.x + 1, y: origin.y - 1, links: [0] }          # 4
        ]
      )

      tree = state.tree

      tree.nodes.each_with_index do |node, index|
        state.graphic_nodes << Node.new(index, node.x, node.y, node.color)
        node.links.each do |linked_node_id|
          state.lines << Line.new(
            index, linked_node_id, tree.nodes
          )
        end
      end
    end

    def render
      draw_bg(args, BLACK)
      render_ui
      render_scene
      render_camera
    end

    def render_ui
      args.outputs.primitives << {
        x: 0, y:  80.from_top,
        w: 360, h: 80,
        r: 0, g: 0, b: 0, a: 128
      }.solid!
      args.outputs.primitives << {
        x: 10, y: 10.from_top,
        text: 'insert text for UI here',
        r: 255, g: 255, b: 255
      }.label!
    end

    def render_scene
      args.outputs[:scene].w = args.state.world.w
      args.outputs[:scene].h = args.state.world.h

      args.outputs[:scene].primitives << state.lines.map(&:render)
      args.outputs[:scene].primitives << state.graphic_nodes.map(&:render)
    end

    def render_camera
      scene_position = calc_scene_position
      args.outputs.sprites << {
        x: scene_position.x,
        y: scene_position.y,
        w: scene_position.w,
        h: scene_position.h,
        path: :scene
      }
    end

    def move_cursor
      return unless args.inputs.directional_angle

      args.state.cursor.x += args.inputs.directional_angle.vector_x * 5
      args.state.cursor.y += args.inputs.directional_angle.vector_y * 5
      args.state.cursor.x = args.state.cursor.x.clamp(0, args.state.world.w - args.state.cursor.size)
      args.state.cursor.y = args.state.cursor.y.clamp(0, args.state.world.h - args.state.cursor.size)
    end

    def move_with_mouse
      mouse = args.inputs.mouse

      return unless mouse.held

      args.state.cursor.x -= mouse.relative_x
      args.state.cursor.y -= mouse.relative_y
    end

    def handle_zoom
      if args.inputs.keyboard.kp_plus && Kernel.tick_count.zmod?(3)
        args.state.camera.scale += 0.05
      elsif args.inputs.keyboard.kp_minus && Kernel.tick_count.zmod?(3)
        args.state.camera.scale -= 0.05
      end

      if args.inputs.mouse.wheel && Kernel.tick_count.zmod?(2)
        args.state.camera.scale += 0.05 * args.inputs.mouse.wheel.y.to_f
      end

      args.state.camera.scale = args.state.camera.scale.greater(0.1)
    end

    def calc_scene_position
      {
        x: args.state.camera.x - (args.state.cursor.x * args.state.camera.scale),
        y: args.state.camera.y - (args.state.cursor.y * args.state.camera.scale),
        w: args.state.world.w * args.state.camera.scale,
        h: args.state.world.h * args.state.camera.scale,
        scale: args.state.camera.scale
      }
    end
  end

  def args
    $gtk.args
  end

  def state
    args.state
  end
end
