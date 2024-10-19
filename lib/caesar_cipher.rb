require_relative 'monoalphabetic_substitution_cipher'

class CaesarCipher
  def initialize(key:)
    @shift = validate_shift(key)
  end

  def encrypt(text)
    cipher.encrypt(text)
  end

  def decrypt(text)
    cipher.decrypt(text)
  end

  def encrypt_file(input_path, output_path)
    content = File.read(input_path)
    encrypted_content = encrypt(content)
    File.write(output_path, encrypted_content)
  end

  def decrypt_file(input_path, output_path)
    content = File.read(input_path)
    decrypted_content = decrypt(content)
    File.write(output_path, decrypted_content)
  end

  private

  attr_reader :shift

  def cipher
    @cipher ||= MonoalphabeticSubstitutionCipher.new(key: generate_caesar_key)
  end

  def generate_caesar_key
    alphabet = ('A'..'Z').to_a
    shifted_alphabet = alphabet.rotate(shift)
    shifted_alphabet.join
  end

  def validate_shift(shift)
    unless shift.is_a?(Integer)
      raise ArgumentError, "Key must be an integer, got #{shift.class}"
    end

    shift % 26
  end
end
