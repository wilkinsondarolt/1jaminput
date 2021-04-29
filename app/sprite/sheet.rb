module Sprite
  class Sheet
    def self.render(opts)
      height = opts[:h]
      width = opts[:w]
      sprite_index = 0.frame_index(
        count: opts[:count],
        hold_for: opts[:hold_for] || 1,
        repeat: true
      )

      {
        x: opts[:x],
        y: opts[:y],
        w: width,
        h: width,
        path: opts[:path],
        source_x: width * sprite_index,
        source_y: 0,
        source_w: width,
        source_h: height
      }
    end
  end
end
