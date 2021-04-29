require 'app/sprite/static.rb'
require 'app/scene/game.rb'

module Scene
  class Title
    def tick(args)
      args.outputs.sprites << Sprite::Static.render(
        x: 0,
        y: 0,
        w: args.grid.w,
        h: args.grid.h,
        path: 'sprites/title/background.png'
      )

      args.outputs.sprites << Sprite::Static.render(
        x: 0,
        y: 50,
        w: args.grid.w,
        h: 389,
        path: 'sprites/title/title.png'
      )

      start_game(args) if args.inputs.mouse.button_left
    end

    private

    def start_game(args)
      args.state.scene = Scene::Game.new
    end
  end
end
