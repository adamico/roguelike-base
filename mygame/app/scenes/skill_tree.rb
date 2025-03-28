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
      args.grid.origin_center!
      args.state.world ||= { w: 1280, h: 720 }
      args.state.camera ||= { x: -(1280 / 2), y: -(720 / 2), scale: 1.0 }
      args.state.cursor ||= { x: 0, y: 0, size: 32 }
    end

    def setup_tree
      mouse = args.inputs.mouse
      state.graphic_nodes = []
      state.rect_nodes = []
      state.node_lines = []
      state.node_labels = []
      state.tree = create_tree

      tree = state.tree
      offset = 8
      size = 32

      tree.nodes.each_with_index do |node, index|
        state.graphic_nodes << Node.new(
          {
            node_id: index,
            x: (offset + size) * node.x, y: (offset + size) * node.y,
            w: size, h: size,
            color: node.color
          }
        )
        state.rect_nodes << {
          x: (offset + size) * node.x, y: (offset + size) * node.y,
          w: size, h: size,
          r: 255, g: 255, b: 255
        }.solid!
        node.links.each do |linked_node_id|
          state.node_lines << Line.new(
            {
              node1: tree.nodes[index],
              node2: tree.nodes[linked_node_id]
            }
          )
        end

        state.node_labels << label_for(node, mouse.x, mouse.y) if mouse_hovering(node)
      end
    end

    def create_tree
      Tree.new(
        [
          { color: 'white', x: 0, y: 0, crystal: nil, links: [1, 3, 4] }, # 0
          { color: 'orange', x: -1, y: 1, crystal: 'Mana Guard', links: [0, 2] }, # 1
          { color: 'violet', x: -1, y: 2, crystal: 'Mana Sight', links: [1] },    # 2
          { color: 'blue', x: 0, y: 1, crystal: 'Fae Bramble Bush', links: [0] }, # 3
          { color: 'red', x: 1, y: 1, crystal: 'Storm', links: [0] } # 4
        ]
      )
    end

    def mouse_hovering(node)
      offset = 8
      size = 32
      total = offset + size
      mouse = args.inputs.mouse
      mouse.inside_rect?(
        {
          x: (node.x * total) - (state.cursor.x * args.state.camera.scale),
          y: (node.y * total) - (state.cursor.y * args.state.camera.scale),
          w: size, h: size
        }
      )
    end

    def render
      draw_bg(args, BLACK)
      render_skill_tree_ui
      render_node_labels
      render_scene
      render_camera
    end

    def render_node_labels
      args.outputs.primitives << state.node_labels
    end

    def label_for(node, x, y)
      return unless node.crystal

      offset_x = 16
      offset_y = 16
      text = node.crystal
      text_width = (text.length * 10) + (offset_x * 2)
      text_height = offset_y * 4
      [
        {
          x: x, y: y - text_height,
          w: text_width, h: text_height,
          r: 0, g: 0, b: 0, a: 222
        }.solid!,
        {
          x: x + offset_x, y: y - (text_height / 2) + (offset_y / 2),
          text: text,
          r: 255, g: 255, b: 255
        }.label!
      ]
    end

    def render_skill_tree_ui
      args.outputs.primitives << {
        x: 0, y:  80.from_top,
        w: 360, h: 80,
        r: 0, g: 0, b: 0, a: 128
      }.solid!
      args.outputs.primitives << {
        x: 10, y: 10.from_top,
        text: 'Hello UI!',
        r: 255, g: 255, b: 255
      }.label!
    end

    def render_scene
      args.outputs[:scene].w = args.state.world.w
      args.outputs[:scene].h = args.state.world.h

      # args.outputs[:scene].primitives << state.rect_nodes
      args.outputs[:scene].primitives << state.node_lines.map(&:render)
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

      args.state.camera.scale += 0.05 * args.inputs.mouse.wheel.y.to_f if args.inputs.mouse.wheel

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
