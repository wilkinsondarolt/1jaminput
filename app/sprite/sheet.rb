module Sprite
  class Sheet
    def self.render(opts)
      height = opts[:h]
      width = opts[:w]
      source_w = opts[:source_w]
      source_h = opts[:source_h]
      sprite_index = 0.frame_index(
        count: opts[:count],
        hold_for: opts[:hold_for] || 1,
        repeat: true
      )

      {
        x: opts[:x],
        y: opts[:y],
        w: width,
        h: height,
        path: opts[:path],
        source_x: source_w * sprite_index,
        source_y: 0,
        source_w: source_w,
        source_h: source_h
      }
    end
  end
end
