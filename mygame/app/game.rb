# Manages world and player
# Takes player action, applies it to the player entity, and ticks the world
class Game
  attr_accessor :player_entity

  def initialize(world:)
    @world = world
  end

  def transport_player_to(map, x:, y:)
    @player_entity.place_on map, x: x, y: y
  end

  def current_map
    @player_entity.map
  end

  def tick(input_actions) # -> perform_player_action
    process_input input_actions
    @world.tick if @player_entity.action
  end

  def perform_player_action(action)
    @player_entity.action = action
    @world.tick
  end

  private

  def process_input(input_actions)
    return unless input_actions[:move]

    @player_entity.action = { type: :move, x: input_actions[:move][:x], y: input_actions[:move][:y] }
  end
end
