# A scene represents a discrete state of gameplay. Things like the main menu,
# game over screen, and gameplay.
#
# Define a new scene by adding one to `app/scenes/` and defining a
# `Scene.tick_SCENE_NAME` class method.
#
# The main `#tick` of the game handles delegating to the current scene based on
# the `args.state.scene` value, which is a symbol of the current scene, ex:
# `:gameplay`
module Scene
  class << self
    # Change the current scene, and optionally reset the scene that's begin
    # changed to so any data is cleared out
    # ex:
    #   Scene.switch(args, :gameplay)
    def switch(scene, reset: false, return_to: nil)
      state.scene_to_return_to = return_to if return_to
      state.scene_switch_tick = args.tick_count

      if scene == :back && state.scene_to_return_to
        scene = state.scene_to_return_to
        state.scene_to_return_to = nil
      end

      if reset
        state.send(scene)&.current_option_i = nil
        state.send(scene)&.hold_delay = nil

        # you can also add custom reset logic as-needed for specific scenes
        # here
      end

      state.scene = scene
      raise FinishTick
    end

    def args
      $gtk.args
    end

    def state
      args.state
    end

    def inputs
      args.inputs
    end

    def mouse
      inputs.mouse
    end

    def outputs
      args.outputs
    end

    def grid
      args.grid
    end
  end
end
