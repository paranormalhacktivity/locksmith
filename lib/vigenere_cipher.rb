require_relative 'polyalphabetic_substitution_cipher'

class VigenereCipher
  def initialize(key:)
    @key = validate_key(key)
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

  attr_reader :key

  def cipher
    @cipher ||= PolyalphabeticSubstitutionCipher.new(key: key)
  end

  def validate_key(key)
    unless !key.empty?
      raise ArgumentError, "Key cannot be empty"
    end

    unless key.match?(/\A[A-Za-z]+\z/)
      raise ArgumentError, "Key must contain only alphabetic characters"
    end

    key.upcase
  end
end
