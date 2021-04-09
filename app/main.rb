def tick(args)
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

def input_time_to_morse_code(input_time)
  seconds = ticks_to_seconds(input_time)

  return '' if seconds.zero?

  if seconds <= 0.13
    '.'
  else
    '-'
  end
end

def ticks_to_seconds(tick_count)
  tick_count / 60
end

def morse_to_alphabet(morse)
  morse_code_alphabet = {
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
  }

  morse_code_alphabet[morse] || ''
end
