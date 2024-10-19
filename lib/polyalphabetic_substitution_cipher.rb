class PolyalphabeticSubstitutionCipher
  def initialize(key:)
    @key = key.upcase
    validate_key(@key)
    @key_shifts = generate_key_shifts(@key)
  end

  def encrypt(text)
    transform(text, :encrypt)
  end

  def decrypt(text)
    transform(text, :decrypt)
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
    unless !key.empty?
      raise ArgumentError, "Key cannot be empty"
    end

    unless key.match?(/\A[A-Za-z]+\z/)
      raise ArgumentError, "Key must contain only alphabetic characters"
    end
  end

  def generate_key_shifts(key)
    key.chars.map { |char| char.ord - 'A'.ord }
  end

	def transform(text, mode)
		key_length = @key_shifts.length
		key_index = 0  # Separate index to track the position in the key
		text.chars.map do |char|
			if char =~ /[A-Za-z]/
				is_upper = char == char.upcase
				base = is_upper ? 'A'.ord : 'a'.ord
				shift = @key_shifts[key_index % key_length]
				shift = -shift if mode == :decrypt
				key_index += 1  # Only advance the key when an alphabetic character is processed
				(((char.ord - base + shift) % 26) + base).chr
			else
				char  # Non-alphabetic characters remain unchanged
			end
		end.join
	end
end
