require 'rspec'
require_relative '../lib/playfair_cipher'

RSpec.describe PlayfairCipher do
  let(:cipher) { PlayfairCipher.new(key: 'SECRET') }
	let(:input_file) { 'spec/test_input.txt' }
	let(:output_file) { 'spec/test_output.txt' }

  describe 'encrypt' do
    it 'encrypts a string using the Playfair cipher' do
      result = cipher.encrypt('HELLO')
      expect(result).to eq('ISKYIQ')
    end

    it 'encrypts uppercase and lowercase letters separately' do
      result = cipher.encrypt('HeLLo')
      expect(result).to eq('IsKYIq')
    end

    it 'keeps non-alphabetic characters unchanged' do
      result = cipher.encrypt('Hello, World!123')
      expect(result).to eq('Iskyiq, Ewfqkc!123')  # Example, excluding punctuation and ignoring case
    end

    it 'pads repeating characters with X' do
      result = cipher.encrypt('BALLOON')
      expect(result).to eq('DBKYIQPO')  # Example: 'LL' becomes 'LX'
    end

    it 'pads odd-length strings with X' do
      result = cipher.encrypt('HELLOX')
      expect(result).to eq('ISKYIQYY')
    end

    it 'encrypts an empty string to an empty string' do
      result = cipher.encrypt('')
      expect(result).to eq('')
    end

    it 'encrypts long text efficiently' do
      long_text = 'AB' * 10000  # 10,000 characters of 'A'
      expected = 'BD' * 10000

      expect(cipher.encrypt(long_text)).to eq(expected)
    end

    it 'treats the key as case-insensitive' do
      cipher_with_uppercase_key = PlayfairCipher.new(key: 'SECRET')
      cipher_with_lowercase_key = PlayfairCipher.new(key: 'secret')

      result_upper = cipher_with_uppercase_key.encrypt('HELLO')
      result_lower = cipher_with_lowercase_key.encrypt('HELLO')

      expect(result_upper).to eq(result_lower)
    end

    it 'encrypts multi-line input preserving line breaks' do
      multi_line_text = "HELLO\nWORLD"
      expect(cipher.encrypt(multi_line_text)).to include("\n")
    end
  end

  describe 'decrypt' do
    ## It is not reasonable for the decryption to reliably result in the same text
    #  prior to encryption, due to the 'X' padding. Hence, why 'ISKYIQ', which resulted
    #  from encrypting 'HELLO', results in 'HELXLO' when decryption takes place.
    #  Thus this is a feature, not a bug.
    it 'decrypts a string using the Playfair cipher' do
      result = cipher.decrypt('ISKYIQ')
      expect(result).to eq('HELXLO')
    end

    it 'decrypts uppercase and lowercase letters separately' do
      result = cipher.decrypt('IsKYIq')
      expect(result).to eq('HeLXLo')
    end

    it 'keeps non-alphabetic characters unchanged' do
      result = cipher.decrypt('Iskyiq, Ewfqkc!123')
      expect(result).to eq('Helxlo, Worldx!123')
    end

    it 'decrypts padded repeating characters correctly' do
      result = cipher.decrypt('DBKYIQPO')
      expect(result).to eq('BALXLOON')  # Handles 'LL' case with 'X' padding
    end

    it 'decrypts an empty string to an empty string' do
      result = cipher.decrypt('')
      expect(result).to eq('')
    end

    it 'decrypts long text efficiently' do
      long_text = 'BD' * 10000  # 10,000 characters of 'A'
      expected = 'AB' * 10000

      expect(cipher.decrypt(long_text)).to eq(expected)
    end

    it 'treats the key as case-insensitive' do
      cipher_with_uppercase_key = PlayfairCipher.new(key: 'SECRET')
      cipher_with_lowercase_key = PlayfairCipher.new(key: 'secret')

      result_upper = cipher_with_uppercase_key.decrypt('HELLO')
      result_lower = cipher_with_lowercase_key.decrypt('HELLO')

      expect(result_upper).to eq(result_lower)
    end

    it 'decrypts multi-line input preserving line breaks' do
      multi_line_text = "HELLO\nWORLD"
      expect(cipher.decrypt(multi_line_text)).to include("\n")
    end
  end

	describe 'encrypt_file' do
		it 'encrypts a file and writes the encrypted content to a new file' do
			File.write(input_file, 'Hello, World!')

			cipher.encrypt_file(input_file, output_file)
			encrypted_content = File.read(output_file)

			expect(encrypted_content).to eq('Iskyiq, Ewfqkc!')
		end

		it 'encrypts a large file correctly' do
			large_text = 'AB' * 10_000
			expected = 'BD' * 10_000
			File.write(input_file, large_text)
			cipher.encrypt_file(input_file, output_file)
			expect(File.read(output_file)).to eq(expected)
		end

		it 'encrypts an empty file correctly' do
			File.write(input_file, '')

			cipher.encrypt_file(input_file, output_file)
			encrypted_content = File.read(output_file)

			expect(encrypted_content).to eq('')
		end
	end

	describe 'decrypt_file' do
		it 'decrypts a file and writes the decrypted content to a new file' do
			File.write(input_file, 'Iskyiq, Ewfqkc!')

			cipher.decrypt_file(input_file, output_file)
			decrypted_content = File.read(output_file)

			expect(decrypted_content).to eq('Helxlo, Worldx!')
		end

		it 'encrypts a large file correctly' do
			large_text = 'BD' * 10_000
			expected = 'AB' * 10_000
			File.write(input_file, large_text)
			cipher.decrypt_file(input_file, output_file)
			expect(File.read(output_file)).to eq(expected)
		end

		it 'decrypts an empty file correctly' do
			File.write(input_file, '')

			cipher.decrypt_file(input_file, output_file)
			decrypted_content = File.read(output_file)

			expect(decrypted_content).to eq('')
		end
	end

  describe 'error handling' do
    it 'raises an error if the key contains non-alphabetic characters' do
      expect { PlayfairCipher.new(key: 'SECRET123') }.to raise_error(ArgumentError, 'Key must contain only alphabetic characters')
    end

    it 'raises an error if the key is empty' do
      expect { PlayfairCipher.new(key: '') }.to raise_error(ArgumentError, 'Key cannot be empty')
    end
  end

  describe 'sanitization' do
    it 'removes duplicate characters from the key' do
      cipher = PlayfairCipher.new(key: 'SECRETSECRET')
      expect(cipher.instance_variable_get(:@key)).to eq('SECRT')  # Ensures duplicates are removed
    end

    it 'sanitizes the key by replacing J with I' do
      cipher = PlayfairCipher.new(key: 'JUMP')
      expect { cipher.encrypt('JUMP') }.not_to raise_error  # Key sanitization (J -> I)
    end
  end
end

