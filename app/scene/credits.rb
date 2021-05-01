require 'app/sprite/static.rb'
require 'app/scene/title.rb'

module Scene
  class Credits
    def initialize(args)
      args.gtk.stop_music
      args.outputs.sounds << 'sounds/music_title.ogg'
    end

    def tick(args)
      args.outputs.sprites << Sprite::Static.render(
        x: 0,
        y: 0,
        w: args.grid.w,
        h: args.grid.h,
        path: 'sprites/credits/screen.png'
      )

      show_title(args) if args.inputs.mouse.click
    end

    private

    def show_title(args)
      args.state.scene = Scene::Title.new(args, true)
    end
  end
end
