class PlayfairCipher
  def initialize(key:)
		validate_key(key)
    @key = sanitize_key(key)
    @matrix = generate_matrix(@key)
  end

  def encrypt(text)
    process_text(text, :encrypt)
  end

  def decrypt(text)
    process_text(text, :decrypt)
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
    if key.empty?
      raise ArgumentError, 'Key cannot be empty'
    end
    unless key.match?(/\A[A-Za-z]+\z/)
      raise ArgumentError, 'Key must contain only alphabetic characters'
    end
  end

  def sanitize_key(key)
    key = key.upcase.gsub(/[^A-Z]/, '')  # Remove non-alphabetic characters
    key.gsub('J', 'I').chars.uniq.join    # Replace J with I (standard Playfair convention)
  end

  def generate_matrix(key)
    alphabet = ('A'..'Z').to_a - ['J']  # Alphabet without J
    combined = (key.chars + alphabet).uniq  # Combine key with remaining alphabet
    combined.each_slice(5).to_a  # Create a 5x5 matrix
  end

  def process_text(text, mode)
    # Prepare digraphs, duplicating non-alphabetic characters
    digraphs = prepare_text(text)

    # Encrypt or decrypt the digraphs
    transformed_text = digraphs.map do |pair|
      if pair[0] == pair[1] && pair[0] =~ /[^A-Za-z]/
        pair[0]  # Condense duplicated non-alphabetic characters back to one
      else
        result = mode == :encrypt ? encrypt_pair(pair) : decrypt_pair(pair)
        preserve_case(pair, result)
      end
    end

    transformed_text.join
  end

  def prepare_text(text)
    digraphs = []
    buffer = []

    text.each_char do |char|
      if char =~ /[A-Za-z]/
        char = char.gsub('J', 'I').gsub('j', 'i')  # Standardize alphabetic chars, replace J with I

        if buffer.empty?
          buffer << char
        elsif buffer[0] == char  # Handle repeating characters
					if buffer[0] =~ /[a-z]/
						buffer << 'x'
					else
						buffer << 'X'
					end
          digraphs << buffer
          buffer = [char]  # Start a new digraph with the current letter
        else
          buffer << char
          digraphs << buffer
          buffer = []  # Clear the buffer after forming a valid digraph
        end
      else
        # If we hit a non-alphabetic character, treat the current buffer as a digraph
				if buffer.any?
					if buffer[0] =~ /[a-z]/ && buffer.size == 1
						buffer << 'x' # Pad single alphabetic letter with X
					elsif buffer.size == 1
						buffer << 'X' # Pad single alphabetic letter with X
					end
          digraphs << buffer
          buffer = []
        end
        # Non-alphabetic characters form their own digraph
        digraphs << [char, char]
      end
    end

    # Handle any leftover alphabetic character in the buffer
    if buffer.any?
      buffer << 'X' if buffer.size == 1
      digraphs << buffer
    end

    digraphs
  end

  def encrypt_pair(pair)
    row1, col1 = find_position(pair[0].upcase)
    row2, col2 = find_position(pair[1].upcase)

    if row1 == row2
      # Same row, move right
      @matrix[row1][(col1 + 1) % 5] + @matrix[row2][(col2 + 1) % 5]
    elsif col1 == col2
      # Same column, move down
      @matrix[(row1 + 1) % 5][col1] + @matrix[(row2 + 1) % 5][col2]
    else
      # Rectangle, swap columns
      @matrix[row1][col2] + @matrix[row2][col1]
    end
  end

  def decrypt_pair(pair)
    row1, col1 = find_position(pair[0].upcase)
    row2, col2 = find_position(pair[1].upcase)

    if row1 == row2
      # Same row, move left
      @matrix[row1][(col1 - 1) % 5] + @matrix[row2][(col2 - 1) % 5]
    elsif col1 == col2
      # Same column, move up
      @matrix[(row1 - 1) % 5][col1] + @matrix[(row2 - 1) % 5][col2]
    else
      # Rectangle, swap columns
      @matrix[row1][col2] + @matrix[row2][col1]
    end
  end

  def find_position(char)
    @matrix.each_with_index do |row, row_idx|
      col_idx = row.index(char)
      return [row_idx, col_idx] if col_idx
    end
    raise "Character #{char} not found in the matrix"
  end

  def preserve_case(original_pair, transformed_pair)
    transformed_pair.chars.each_with_index.map do |char, idx|
      original_char = original_pair[idx]
      original_char == original_char.upcase ? char.upcase : char.downcase
    end.join
  end
end

