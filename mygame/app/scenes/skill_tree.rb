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
      args.state.world.w ||= 1280
      args.state.world.h ||= 720

      args.state.camera.x                ||= 640
      args.state.camera.y                ||= 300
      args.state.camera.scale            ||= 1.0
      args.state.camera.show_empty_space ||= :yes

      args.state.cursor.x ||= 640
      args.state.cursor.y ||= 300
      args.state.cursor.size ||= 32

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
      args.outputs.primitives << { x: 0, y:  80.from_top, w: 360, h: 80, r: 0, g: 0, b: 0, a: 128 }.solid!
      args.outputs.primitives << { x: 10, y: 10.from_top, text: "arrow keys to move around", r: 255, g: 255, b: 255}.label!
      args.outputs.primitives << { x: 10, y: 30.from_top, text: "+/- to change zoom of camera", r: 255, g: 255, b: 255}.label!
      args.outputs.primitives << { x: 10, y: 50.from_top, text: "tab to change camera edge behavior", r: 255, g: 255, b: 255}.label!
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
      args.state.cursor.x  = args.state.cursor.x.clamp(0, args.state.world.w - args.state.cursor.size)
      args.state.cursor.y  = args.state.cursor.y.clamp(0, args.state.world.h - args.state.cursor.size)
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
      elsif args.inputs.keyboard.key_down.tab
        if args.state.camera.show_empty_space == :yes
          args.state.camera.show_empty_space = :no
        else
          args.state.camera.show_empty_space = :yes
        end
      end

      args.state.camera.scale = args.state.camera.scale.greater(0.1)
    end

    def calc_scene_position
      result = {
        x: args.state.camera.x - (args.state.cursor.x * args.state.camera.scale),
        y: args.state.camera.y - (args.state.cursor.y * args.state.camera.scale),
        w: args.state.world.w * args.state.camera.scale,
        h: args.state.world.h * args.state.camera.scale,
        scale: args.state.camera.scale
      }

      return result if args.state.camera.show_empty_space == :yes

      if result.w < args.grid.w
        result.merge!(x: (args.grid.w - result.w).half)
      elsif (args.state.cursor.x * result.scale) < args.grid.w.half
        result.merge!(x: 10)
      elsif (result.x + result.w) < args.grid.w
        result.merge!(x: - result.w + (args.grid.w - 10))
      end

      if result.h < args.grid.h
        result.merge!(y: (args.grid.h - result.h).half)
      elsif result.y > 10
        result.merge!(y: 10)
      elsif (result.y + result.h) < args.grid.h
        result.merge!(y: - result.h + (args.grid.h - 10))
      end

      result
    end
  end



  class Tree
    attr_reader :nodes

    def initialize(nodes)
      @nodes = nodes
    end
  end

  class Line
    def initialize(id1, id2, nodes)
      @id1 = id1
      @id2 = id2
      @node1 = nodes[id1]
      @node2 = nodes[id2]
    end

    def render
      w = 1
      h = 1
      rect1 = Layout.rect(
        row: @node1.y, col: @node1.x,
        w: w, h: h
      )
      rect2 = Layout.rect(
        row: @node2.y, col: @node2.x,
        w: w, h: h
      )

      center1 = Geometry.rect_center_point(rect1)
      center2 = Geometry.rect_center_point(rect2)
      {
        x: center1.x,
        y: center1.y,
        x2: center2.x,
        y2: center2.y,
        r: 255,
        g: 255,
        b: 255,
        a: 255
      }
    end
  end

  class Node
    def initialize(id, x, y, color = WHITE)
      @id = id
      @x = x
      @y = y
      @color = color
    end

    def render
      rect = Layout.rect(
        row: @y, col: @x,
        w: 1, h: 1
      )
      center = Geometry.rect_center_point(rect)
      {
        x: center.x,
        y: center.y,
        anchor_x: 0.5,
        anchor_y: 0.5,
        w: rect.w,
        h: rect.h,
        path: "sprites/circle/#{@color}.png"
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
