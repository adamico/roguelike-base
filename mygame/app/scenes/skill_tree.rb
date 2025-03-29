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
      w = grid.right
      h = grid.top
      size = 32
      x = (w / 2) - (size / 2)
      y = (h / 2) - (size / 2)

      state.world  ||= { w: w, h: h }
      state.cursor ||= {
        x: x, y: y, w: size, h: size,
        path: :solid, r: 255, g: 255, b: 255
      }
      state.camera ||= { x: x, y: y, scale: 1.0 }
    end

    def setup_tree
      state.graphic_nodes = []
      state.rect_nodes = []
      state.node_lines = []
      state.node_labels = []
      state.tree ||= create_tree

      tree = state.tree
      size = 32

      tree.nodes.each_with_index do |node, index|
        state.graphic_nodes << Node.new(
          {
            node_id: index,
            x: node.x, y: node.y,
            w: size, h: size,
            color: node.color
          }
        )
        state.rect_nodes << {
          x: node.x, y: node.y,
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
      w = grid.right
      h = grid.top
      size = 32
      x = (w / 2) - (size / 2)
      y = (h / 2) - (size / 2)
      Tree.new(
        [
          { color: 'white', x: x, y: y, crystal: nil, links: [1, 3, 4] }, # 0
          { color: 'orange', x: x - size, y: y + size, crystal: 'Mana Guard', links: [0, 2] }, # 1
          { color: 'violet', x: x - size, y: y + (size * 2), crystal: 'Mana Sight', links: [1] }, # 2
          { color: 'blue', x: x, y: y + size, crystal: 'Fae Bramble Bush', links: [0] }, # 3
          { color: 'red', x: x + size, y: y + size, crystal: 'Storm', links: [0] } # 4
        ]
      )
    end

    def mouse_hovering(node)
      size = 32
      mouse.inside_rect?(
        {
          x: node.x - (state.cursor.x - (state.world.w / 2) + 16),
          y: node.y - (state.cursor.y - (state.world.h / 2) + 16),
          w: size * state.camera.scale, h: size * state.camera.scale
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
      outputs.primitives << state.node_labels
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
      outputs.primitives << {
        x: 0, y:  80.from_top,
        w: 360, h: 80,
        r: 0, g: 0, b: 0, a: 128
      }.solid!
      outputs.primitives << {
        x: 10, y: 10.from_top,
        text: 'Hello UI!',
        r: 255, g: 255, b: 255
      }.label!
    end

    def render_scene
      outputs[:scene].w = state.world.w
      outputs[:scene].h = state.world.h

      # outputs[:scene].primitives << state.rect_nodes

      # outputs[:scene].primitives << {
      #   x: 0, y: 0,
      #   w: state.world.w, h: state.world.h,
      #   r: 20, g: 60, b: 80,
      #   path: :solid
      # }
      outputs[:scene].primitives << state.cursor
      outputs[:scene].primitives << state.node_lines.map(&:render)
      outputs[:scene].primitives << state.graphic_nodes.map(&:render)
    end

    def render_camera
      scene_position = calc_scene_position
      outputs.sprites << {
        x: scene_position.x,
        y: scene_position.y,
        w: scene_position.w,
        h: scene_position.h,
        path: :scene
      }
    end

    def move_cursor
      return unless inputs.directional_angle

      state.cursor.x += inputs.directional_angle.vector_x * 5
      state.cursor.y += inputs.directional_angle.vector_y * 5
    end

    def move_with_mouse
      return unless mouse.held

      state.cursor.x -= mouse.relative_x
      state.cursor.y -= mouse.relative_y
    end

    def handle_zoom
      if inputs.keyboard.kp_plus && Kernel.tick_count.zmod?(3)
        state.camera.scale += 0.05
      elsif inputs.keyboard.kp_minus && Kernel.tick_count.zmod?(3)
        state.camera.scale -= 0.05
      end

      state.camera.scale += 0.05 * inputs.mouse.wheel.y.to_f if inputs.mouse.wheel

      state.camera.scale = state.camera.scale.greater(0.1)
    end

    def calc_scene_position
      {
        x: state.camera.x - (state.cursor.x * state.camera.scale),
        y: state.camera.y - (state.cursor.y * state.camera.scale),
        w: state.world.w * state.camera.scale,
        h: state.world.h * state.camera.scale,
        scale: state.camera.scale
      }
    end
  end

  def args
    $gtk.args
  end

  def state
    state
  end
end
