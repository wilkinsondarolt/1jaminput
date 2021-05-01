require 'app/sprite/static.rb'
require 'app/scene/game.rb'

module Scene
  class Title
    def initialize(args, restart)
      return if restart

      args.audio = {}
      args.audio[:music] = {
        input: 'sounds/music_title.ogg',
        x: 0.0,
        y: 0.0,
        z: 0.0,
        paused: false,
        looping: true
      }
    end

    def tick(args)
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

      args.outputs.sprites << Sprite::Static.render(
        x: 0,
        y: 100,
        w: args.grid.w,
        h: 500,
        path: 'sprites/title/title.png'
      )

      start_game(args) if args.inputs.mouse.click
    end

    private

    def start_game(args)
      args.state.scene = Scene::Game.new(args)
    end
  end
end
