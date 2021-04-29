require 'app/scene/game.rb'
require 'app/scene/title.rb'

def tick(args)
  args.state.scene ||= Scene::Title.new

  args.state.scene.tick(args)
end
