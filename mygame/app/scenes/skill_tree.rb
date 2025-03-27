Origin = Struct.new(:x, :y)

module Scene
  class << self
    def tick_skill_tree(_args)
      setup
      render
    end

    def setup
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
      args.outputs.primitives << state.lines.map(&:render)
      args.outputs.primitives << state.graphic_nodes.map(&:render)
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
