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
    rect1 = layout_for(@node1)
    rect2 = layout_for(@node2)

    center1 = Geometry.rect_center_point(rect1)
    center2 = Geometry.rect_center_point(rect2)
    {
      x: center1.x, y: center1.y,
      x2: center2.x, y2: center2.y,
      r: 255, g: 255, b: 255, a: 255
    }
  end

  def layout_for(node, w = 1, h = 1)
    Layout.rect(
      row: node.y, col: node.x,
      w: w, h: h
    )
  end
end

class Node
  def initialize(node_id, x, y, color = WHITE)
    @id = node_id
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
