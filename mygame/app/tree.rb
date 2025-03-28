class Tree
  attr_reader :nodes

  def initialize(nodes)
    @nodes = nodes
  end
end

class Node
  def initialize(params)
    @id = params.node_id
    @x = params.x
    @y = params.y
    @color = params.color || WHITE
    @w = params.w
    @h = params.h
  end

  def render
    {
      x: @x,
      y: @y,
      w: @w,
      h: @h,
      path: "sprites/circle/#{@color}.png"
    }
  end
end

class Line
  def initialize(params)
    @size = 32
    @offset = 8
    @node1 = params.node1
    @node2 = params.node2
    @rect1 = Geometry.rect_props(rect_for(@node1))
    @rect2 = Geometry.rect_props(rect_for(@node2))
  end

  def render
    {
      x: (@node1.x * offset) + (@size / 2), y: (@node1.y * offset) + (@size / 2),
      x2: (@node2.x * offset) + (@size / 2), y2: (@node2.y * offset) + (@size / 2),
      r: 255, g: 255, b: 255, a: 255
    }
  end

  def rect_for(node)
    {
      x: offset * node.x, y: offset * node.y,
      w: @size, h: @size
    }
  end

  def offset
    @offset + @size
  end
end
