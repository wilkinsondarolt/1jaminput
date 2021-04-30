class MorseCode
  DOT_SYMBOL = '.'.freeze
  SLASH_SYMBOL = '-'.freeze
  MORSE_CODE_ALPHABET = {
    '-.' => 'N',
    '...' => 'S'
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
