module Sprite
  class Static
    def self.render(opts)
      [opts[:x], opts[:y], opts[:w], opts[:h], opts[:path]]
    end
  end
end
