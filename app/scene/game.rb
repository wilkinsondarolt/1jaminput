require 'app/sprite/parallax.rb'
require 'app/sprite/static.rb'
require 'app/sprite/sheet.rb'
require 'app/morse_code.rb'
require 'app/scene/credits.rb'

module Scene
  class Game
    def tick(args)
      draw_background(args)

      reset_variables(args) if args.state.mouse_tick.nil?
      args.state.difficulty_multiplier = difficulty_multiplier(args.state.tick_count)

      args.outputs.debug << [120, 100, "Dificuldade: #{args.state.difficulty_multiplier}", 1, 1].label

      draw_player(args)

      if args.inputs.mouse.button_left
        draw_lighthouse_light(args)
        args.state.mouse_tick += 1
        args.state.idle_time = 0
      else
        args.state.idle_time += 1
      end

      input_kind = MorseCode.input_time_to_morse_code(args.state.mouse_tick)

      draw_morse_signals(args)

      if ticks_to_seconds(args.state.idle_time) >= 0.5 && args.state.morse_signals.size >= 1
        morse_code_letter = args.state.morse_signals.join('')
        alphabet_letter = MorseCode.morse_to_alphabet(morse_code_letter)

        directions = {
          'N' => 1,
          'S' => -1
        }
        direction = directions[alphabet_letter] || 0

        args.state.player_lane += direction
        args.state.player_lane = 3 if args.state.player_lane > 3
        args.state.player_lane = 1 if args.state.player_lane <= 0
        args.state.morse_signals = []
      end

      if ticks_to_seconds(args.state.idle_time) >= 1.5 && args.state.letters.size >= 1
        args.state.letters = []
      end

      if args.inputs.mouse.up
        args.state.morse_signals << input_kind
        args.state.mouse_tick = 0
      end

      generate_stone(args) if create_stone?

      clear_unused_stones(args)
      update_stones(args)
      draw_stones(args)

      end_game(args) if player_collinding_with_stone?(args)
    end

    private

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
      args.state.stones = args.state.stones.reject do |stone|
        stone[:x] < -300
      end
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

    def reset_variables(args)
      args.state.mouse_tick = 0
      args.state.idle_time = 0
      args.state.morse_signals = []
      args.state.stones = []
      args.state.player_lane = 2
    end

    def end_game(args)
      reset_variables(args)

      args.state.scene = Scene::Credits.new
    end

    def draw_stones(args)
      args.state.stones.each do |stone|
        args.outputs.sprites << Sprite::Static.render(
          x: stone[:x],
          y: stone[:y],
          w: 200,
          h: 130,
          path: "sprites/stone/stone#{stone[:sprite_index]}.png"
        )

        args.outputs.debug << stone[:collision_box].border
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
