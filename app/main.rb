require 'app/scene/game.rb'

def tick(args)
  args.state.scene ||= Scene::Game.new

  args.state.scene.tick(args)
end
