module Sprite
  class Parallax
    WINDOW_HEIGHT = 720
    WINDOW_WIDTH = 1440

    def self.render(tick:, path:, rate:, y: 0)
      [
        [0 - tick.*(rate) % WINDOW_WIDTH, y, WINDOW_WIDTH, WINDOW_HEIGHT, path],
        [WINDOW_WIDTH - tick.*(rate) % WINDOW_WIDTH, y, WINDOW_WIDTH, WINDOW_HEIGHT, path]
      ]
    end
  end
end
