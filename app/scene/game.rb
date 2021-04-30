require 'app/sprite/parallax.rb'
require 'app/sprite/static.rb'
require 'app/sprite/sheet.rb'
require 'app/morse_code.rb'

module Scene
  class Game
    def tick(args)
      draw_background(args)

      args.state.mouse_tick ||= 0
      args.state.idle_time ||= 0
      args.state.morse_signals ||= []
      args.state.letters ||= []
      args.state.stones ||= []
      args.state.player_lane ||= 2

      draw_player(args)

      if args.inputs.mouse.button_left
        draw_lighthouse_light(args)
        args.state.mouse_tick += 1
        args.state.idle_time = 0
      else
        args.state.idle_time += 1
      end

      input_kind = MorseCode.input_time_to_morse_code(args.state.mouse_tick)

      args.state.morse_signals.each_with_index do |code, index|
        x_position = 50 + (80 * index)
        y_position = 50

        args.outputs.labels << [x_position, y_position, code, 5, 1]
      end

      args.state.letters.each_with_index do |letter, index|
        x_position = 100 + (80 * index)
        y_position = 100

        args.outputs.labels << [x_position, y_position, letter, 5, 1]
      end

      args.outputs.labels << [640, 420, input_kind, 5, 1]

      if ticks_to_seconds(args.state.idle_time) >= 0.5 && args.state.morse_signals.size >= 1
        morse_code_letter = args.state.morse_signals.join('')
        alphabet_letter = MorseCode.morse_to_alphabet(morse_code_letter)

        args.state.letters << alphabet_letter unless alphabet_letter.empty?
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
    end

    private

    def random(min, max)
      [*min..max].sample
    end

    def generate_stone(args)
      stone = {
        sprite_index: random(1, 3),
        lane: random(1, 4),
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
        stone[:collision_box] = stone_collision_box = {
          x: stone[:x],
          y: stone[:y] + 60,
          w: 200,
          h: 60
        }
      end
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

    def ticks_to_seconds(tick_count)
      tick_count / 60
    end

    def draw_background(args)
      args.outputs.sprites << Sprite::Parallax.render(
        tick: args.state.tick_count,
        path: 'sprites/background/sky.png',
        rate: -0.75
      )

      args.outputs.sprites << Sprite::Static.render(
        x: 420,
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
    end

    def draw_player(args)
      args.outputs.sprites << Sprite::Sheet.render(
        tick: args.state.tick_count,
        count: 4,
        hold_for: 20,
        x: 100,
        y: 130.*(args.state.player_lane - 1),
        source_w: 299,
        source_h: 189,
        w: 200,
        h: 130,
        path: 'sprites/boat/boat_spritesheet.png'
      )

      args.state.player.collision_box = {
        x: 120,
        y: 150.*(args.state.player_lane - 1),
        h: 50,
        w: 160
      }

      args.outputs.debug << args.state.player.collision_box.border
    end

    def draw_lighthouse_light(args)
      args.outputs.sprites << Sprite::Static.render(
        x: 0,
        y: args.grid.h - 340,
        w: 1400,
        h: 360,
        path: 'sprites/light/light.png'
      )
    end
  end
end
