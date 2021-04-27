module Sprite
  class Parallax
    WINDOW_HEIGHT = 720
    WINDOW_WIDTH = 1440

    def self.render(at, path, rate, y = 0)
      [
        [0 - at.*(rate) % WINDOW_WIDTH, y, WINDOW_WIDTH, WINDOW_HEIGHT, path],
        [WINDOW_WIDTH - at.*(rate) % WINDOW_WIDTH, y, WINDOW_WIDTH, WINDOW_HEIGHT, path]
      ]
    end
  end
end
