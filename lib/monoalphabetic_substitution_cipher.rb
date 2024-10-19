class MonoalphabeticSubstitutionCipher
  def initialize(key:)
    @key = key.upcase
    validate_key(@key)
    @cipher_map = generate_cipher_map(@key)
    @reverse_cipher_map = @cipher_map.invert
  end

  def encrypt(text)
    transform(text, @cipher_map)
  end

  def decrypt(text)
    transform(text, @reverse_cipher_map)
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

  def validate_key(key)
    unless key.length == 26 && key.chars.uniq.length == 26 && key.match?(/\A[A-Z]+\z/)
      raise ArgumentError, "Key must be 26 unique alphabetic characters"
    end
  end

  def transform(text, map)
    text.chars.map do |char|
      if char =~ /[A-Za-z]/
        is_upper = char == char.upcase
        mapped_char = map[char.upcase]
        is_upper ? mapped_char : mapped_char.downcase
      else
        char
      end
    end.join
  end

  def generate_cipher_map(key)
    plain_alphabet = ('A'..'Z').to_a
    cipher_alphabet = key.chars
    Hash[plain_alphabet.zip(cipher_alphabet)]
  end
end
