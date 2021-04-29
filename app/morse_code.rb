class MorseCode
  DOT_SYMBOL = '.'.freeze
  SLASH_SYMBOL = '-'.freeze
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

  def self.input_time_to_morse_code(input_time)
    seconds = input_time / 60

    return '' if seconds.zero?

    seconds <= 0.13 ? DOT_SYMBOL : SLASH_SYMBOL
  end

  def self.morse_to_alphabet(morse)
    MORSE_CODE_ALPHABET[morse] || ''
  end
end
