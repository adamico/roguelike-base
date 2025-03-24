require 'lib/draco'

require 'app/input'
require 'app/sprite'
require 'app/util'

require 'app/constants'
require 'app/menu'
require 'app/scene'
require 'app/game_setting'
require 'app/sound'
require 'app/text'

# Scenes
require 'app/scenes/gameplay'
require 'app/scenes/main_menu'
require 'app/scenes/paused'
require 'app/scenes/settings'

# Entities
require 'app/entities/player'

require 'lib/tilemap'

require 'lib/deep_dup'
require 'lib/component_definitions'
require 'lib/entity_store'
require 'lib/string_utf8_chars'
require 'lib/cp437_spritesheet_tileset'
require 'lib/map_renderer'

require 'app/components'
require 'app/entity_types'
require 'app/game'
require 'app/tileset'
require 'app/world'

# NOTE: add all requires above this

require 'app/tick'
