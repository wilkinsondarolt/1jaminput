require 'app/sprite/static.rb'
require 'app/scene/title.rb'

module Scene
  class Credits
    def initialize(args)
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
      draw_score(args)

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

    def draw_score(args)
      args.outputs.labels << {
        x: 10,
        y: args.grid.h - 5,
        size_enum: 15,
        text: "Pontuação: #{args.state.score}",
        r: 255,
        g: 255,
        b: 255,
        font: 'fonts/CaveatBrush-Regular.ttf'
      }
    end
  end
end
