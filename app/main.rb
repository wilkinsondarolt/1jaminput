require 'app/sprite/parallax.rb'
require 'app/sprite/static.rb'

def tick(args)
  args.outputs.sprites << Sprite::Parallax.render(args.state.tick_count, 'sprites/background/sky.png', -0.75)
  args.outputs.sprites << Sprite::Static.render(420, 340, 463, 320, 'sprites/background/lighthouse.png')
  args.outputs.sprites << Sprite::Parallax.render(args.state.tick_count, 'sprites/background/ocean_back.png', -1.00, -65)
  args.outputs.sprites << Sprite::Parallax.render(args.state.tick_count, 'sprites/background/ocean_front.png', -1.50, -65)

  args.state.mouse_tick ||= 0
  args.state.idle_time ||= 0
  args.state.morse_signals ||= []
  args.state.letters ||= []

  if args.inputs.mouse.button_left
    args.state.mouse_tick += 1
    args.state.idle_time = 0
  else
    args.state.idle_time += 1
  end

  input_kind = input_time_to_morse_code(args.state.mouse_tick)

  args.state.morse_signals.each_with_index do |code, index|
    x_position = 50 + (80 * index)
    y_position = 50

    args.outputs.labels << [x_position, y_position, code, 5, 1]
  end

  args.state.letters.each_with_index do |letter, index|
    x_position = 100 + (80 * index)
    y_position = 100

    args.outputs.labels << [x_position, y_position, letter, 5, 1]
  end

  args.outputs.labels << [640, 420, input_kind, 5, 1]

  if ticks_to_seconds(args.state.idle_time) >= 0.5 && args.state.morse_signals.size >= 1
    morse_code_letter = args.state.morse_signals.join('')
    alphabet_letter = morse_to_alphabet(morse_code_letter)

    args.state.letters << alphabet_letter unless alphabet_letter.empty?
    args.state.morse_signals = []
  end

  if ticks_to_seconds(args.state.idle_time) >= 1.5 && args.state.letters.size >= 1
    args.state.letters = []
  end

  if args.inputs.mouse.up
    args.state.morse_signals << input_kind
    args.state.mouse_tick = 0
  end
end

MORSE_CODE_DOT_SYMBOL = '.'.freeze
MORSE_CODE_SLASH_SYMBOL = '-'.freeze

def input_time_to_morse_code(input_time)
  seconds = ticks_to_seconds(input_time)

  return '' if seconds.zero?

  seconds <= 0.13 ? MORSE_CODE_DOT_SYMBOL : MORSE_CODE_SLASH_SYMBOL
end

def ticks_to_seconds(tick_count)
  tick_count / 60
end

MORSE_CODE_ALPHABET = {
  '.-' => 'A',
  '-...' => 'B',
  '-.-.' => 'C',
  '-..' => 'D',
  '.' => 'E',
  '..-.' => 'F',
  '--.' => 'G',
  '....' => 'H',
  '..' => 'I',
  '.---' => 'J',
  '-.-' => 'K',
  '.-..' => 'L',
  '--' => 'M',
  '-.' => 'N',
  '---' => 'O',
  '.--.' => 'P',
  '--.-' => 'Q',
  '.-.' => 'R',
  '...' => 'S',
  '-' => 'T',
  '..-' => 'U',
  '...-' => 'V',
  '.--' => 'W',
  '-..-' => 'X',
  '-.--' => 'Y',
  '--..' => 'Z'
}.freeze

def morse_to_alphabet(morse)
  MORSE_CODE_ALPHABET[morse] || ''
end
