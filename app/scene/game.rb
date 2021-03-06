require 'app/sprite/parallax.rb'
require 'app/sprite/static.rb'
require 'app/sprite/sheet.rb'
require 'app/morse_code.rb'
require 'app/scene/credits.rb'

module Scene
  class Game
    def initialize(args)
      reset_variables(args)

      args.audio[:music] = {
        input: 'sounds/music_gameplay.ogg',
        x: 0.0,
        y: 0.0,
        z: 0.0,
        paused: false,
        looping: true
      }

      args.audio[:music_sea] = {
        input: 'sounds/music_gameplay_sea.ogg',
        x: 0.0,
        y: 0.0,
        z: 0.0,
        paused: false,
        looping: true
      }
    end

    def tick(args)
      draw_background(args)
      draw_score(args)

      args.state.game_tick += 1
      args.state.difficulty_multiplier = difficulty_multiplier(args.state.game_tick)

      args.outputs.debug << [120, 100, "Dificuldade: #{args.state.difficulty_multiplier}", 1, 1].label
      args.state.mouse_down_in_game =  args.state.mouse_down_in_game || args.inputs.mouse.down

      if args.state.mouse_down_in_game && args.inputs.mouse.button_left
        draw_lighthouse_light(args)
        args.state.mouse_tick += 1
        args.state.idle_time = 0
      else
        args.state.idle_time += 1
      end

      input_kind = MorseCode.input_time_to_morse_code(args.state.mouse_tick)

      draw_morse_signals(args)

      submit_input = ticks_to_seconds(args.state.idle_time) >= 0.5 && args.state.morse_signals.size >= 1

      move_player(args) if submit_input

      if args.inputs.mouse.up
        args.state.morse_signals << input_kind
        play_morse_code_sound(args, input_kind)

        args.state.mouse_tick = 0
      end

      generate_stone(args) if create_stone?

      clear_unused_stones(args)
      update_stones(args)
      draw_stones(args)

      draw_player(args)
      play_player_horn(args)

      end_game(args) if player_collinding_with_stone?(args)
    end

    private

    def play_morse_code_sound(args, morse_code_symbol)
      morse_code_sound = morse_code_symbol == MorseCode::DOT_SYMBOL ? 'dot' : 'slash'

      args.gtk.queue_sound("sounds/sfx_morse_code_#{morse_code_sound}.ogg")
    end

    def move_player(args)
      morse_code_letter = args.state.morse_signals.join('')
      alphabet_letter = MorseCode.morse_to_alphabet(morse_code_letter)

      directions = { 'N' => 1, 'S' => -1 }
      direction = directions[alphabet_letter] || 0

      args.state.player_lane += direction
      args.state.player_lane = 3 if args.state.player_lane > 3
      args.state.player_lane = 1 if args.state.player_lane <= 0
      args.state.morse_signals = []
    end

    def random(min, max)
      [*min..max].sample
    end

    def generate_stone(args)
      stone = {
        sprite_index: random(1, 3),
        lane: random(1, 3),
        x: args.grid.w
      }

      args.state.stones << stone
    end

    STONE_SPAWN_RATIO = 2

    def create_stone?
      random(1, 100) < STONE_SPAWN_RATIO
    end

    def clear_unused_stones(args)
      stone_count = args.state.stones.count

      args.state.stones = args.state.stones.reject do |stone|
        stone[:x] < -300
      end

      removed_stones = stone_count - args.state.stones.count

      args.state.score += 100.*(removed_stones)
    end

    def update_stones(args)
      args.state.stones.each do |stone|
        stone[:x] -= 3
        stone[:y] = 100.*(stone[:lane] - 1)
        stone_collision_box = {
          x: stone[:x],
          y: stone[:y] + 60,
          w: 200,
          h: 60
        }
        stone[:collision_box] = stone_collision_box
      end
    end

    def player_collinding_with_stone?(args)
      args.state.stones.find do |stone|
        args.state.player.collision_box.intersect_rect?(stone[:collision_box])
      end
    end

    def play_player_horn(args)
      return unless (args.state.game_tick % 3_600).zero?

      args.gtk.queue_sound('sounds/sfx_player_horn.ogg')
    end

    def play_player_death(args)
      args.gtk.queue_sound('sounds/sfx_player_death.ogg')
    end

    def draw_score(args)
      args.outputs.labels << {
        x: 10,
        y: args.grid.h - 5,
        size_enum: 15,
        text: "Pontua????o: #{args.state.score}",
        r: 255,
        g: 255,
        b: 255,
        font: 'fonts/CaveatBrush-Regular.ttf'
      }
    end

    def reset_variables(args)
      args.state.game_tick = 0
      args.state.mouse_tick = 0
      args.state.idle_time = 0
      args.state.morse_signals = []
      args.state.stones = []
      args.state.player_lane = 2
      args.state.mouse_down_in_game = false
      args.state.score = 0
    end

    def end_game(args)
      play_player_death(args)

      args.state.scene = Scene::Credits.new(args)
    end

    def draw_stones(args)

      args.outputs.sprites << args.state.stones.map do |stone|
         Sprite::Static.render(
          x: stone[:x],
          y: stone[:y],
          w: 200,
          h: 130,
          path: "sprites/stone/stone#{stone[:sprite_index]}.png"
        )
      end
    end

    def difficulty_multiplier(tick_count)
      (1 + 0.2.*(ticks_to_minutes(tick_count))).round(1)
    end

    def ticks_to_seconds(tick_count)
      tick_count / 60
    end

    def ticks_to_minutes(tick_count)
      tick_count / 3_600
    end

    def draw_background(args)
      args.outputs.sprites << Sprite::Parallax.render(
        tick: args.state.tick_count,
        path: 'sprites/background/sky.png',
        rate: -0.75
      )

      args.outputs.sprites << Sprite::Static.render(
        x: 400,
        y: 340,
        w: 500,
        h: 380,
        path: 'sprites/background/lighthouse.png'
      )

      args.outputs.sprites << Sprite::Parallax.render(
        tick: args.state.tick_count,
        path: 'sprites/background/ocean_back.png',
        rate: -1.00,
        y: -65
      )

      args.outputs.sprites << Sprite::Parallax.render(
        tick: args.state.tick_count,
        path: 'sprites/background/ocean_front.png',
        rate: -1.50,
        y: -65
      )

      args.outputs.debug << {
        x: (args.grid.w / 2),
        y: 0,
        x2: (args.grid.w / 2),
        y2: args.grid.h
      }
    end

    def draw_player(args)
      y = 50 + 100.*(args.state.player_lane - 1)

      args.outputs.sprites << Sprite::Sheet.render(
        tick: args.state.tick_count,
        count: 4,
        hold_for: 20,
        x: 100,
        y: y,
        source_w: 299,
        source_h: 189,
        w: 200,
        h: 130,
        path: 'sprites/boat/boat_spritesheet.png'
      )

      args.state.player.collision_box = {
        x: 120,
        y: y + 20,
        h: 50,
        w: 160
      }

      args.outputs.debug << args.state.player.collision_box.border
    end

    def draw_lighthouse_light(args)
      args.outputs.sprites << Sprite::Static.render(
        x: -35,
        y: args.grid.h - 340,
        w: 1400,
        h: 360,
        path: 'sprites/light/light.png'
      )
    end

    def draw_morse_signals(args)
      screen_center = args.grid.w / 2
      signal_count = args.state.morse_signals.size
      x = screen_center - (100.*(signal_count) / 2)

      args.state.morse_signals.each do |signal|
        if signal == MorseCode::DOT_SYMBOL
          args.outputs.sprites << Sprite::Static.render(
            x: x,
            y: 0,
            w: 50,
            h: 50,
            path: 'sprites/morse/dot.png'
          )
          x += 100
        else
          args.outputs.sprites << Sprite::Static.render(
            x: x,
            y: 0,
            w: 100,
            h: 50,
            path: 'sprites/morse/slash.png'
          )
          x += 150
        end
      end
    end
  end
end
