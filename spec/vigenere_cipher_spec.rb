require 'rspec'
require_relative '../lib/vigenere_cipher'

RSpec.describe 'Vigenere Cipher' do
  let(:cipher) { VigenereCipher.new(key: 'SECRET') }
  let(:input_file) { 'spec/test_input.txt' }
  let(:output_file) { 'spec/test_output.txt' }

  after do
    File.delete(input_file) if File.exist?(input_file)
    File.delete(output_file) if File.exist?(output_file)
  end

  describe 'encrypt' do
    it 'encrypts a string using the Vigenere cipher' do
      result = cipher.encrypt('HELLO')
      expect(result).to eq('ZINCS')
    end

    it 'encrypts uppercase and lowercase letters separately' do
      result = cipher.encrypt('HeLLo')
      expect(result).to eq('ZiNCs')
    end

    it 'keeps non-alphabetic characters unchanged' do
      expect(cipher.encrypt('hello, world! 123')).to eq('zincs, pgvnu! 123')
    end

    it 'returns an empty string when given an empty input' do
      expect(cipher.encrypt('')).to eq('')
    end

    it 'handles repeating short keys for long text' do
      cipher = VigenereCipher.new(key: 'A')  # A simple key that shouldn't change the text
      result = cipher.encrypt('LONGTEXTWITHSHORTKEY')
      expect(result).to eq('LONGTEXTWITHSHORTKEY')  # A key of 'A' leaves the text unchanged

      cipher = VigenereCipher.new(key: 'B')  # A key that will actually cause a shift, just to feel good
      result = cipher.encrypt('LONG TEXT WITH SHORT KEY')
      expect(result).to eq('MPOH UFYU XJUI TIPSU LFZ')
    end

    it 'encrypts long text efficiently' do
      key = 'SECRET'
      long_text = 'A' * 10000  # 10,000 characters of 'A'
      expected = (key * 1700)[0..9999] # Because it's a single letter 'A', the text should encrypt to match the key
      cipher = VigenereCipher.new(key: key)

      expect(cipher.encrypt(long_text)).to eq(expected)
    end

    it 'treats the key as case-insensitive' do
      cipher_with_uppercase_key = VigenereCipher.new(key: 'SECRET')
      cipher_with_lowercase_key = VigenereCipher.new(key: 'secret')

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
    it 'decrypts a string using the Vigenere cipher' do
      result = cipher.decrypt('ZINCS')
      expect(result).to eq('HELLO')
    end

    it 'decrypts uppercase and lowercase letters separately' do
      result = cipher.decrypt('ZiNCs')
      expect(result).to eq('HeLLo')
    end

    it 'keeps non-alphabetic characters unchanged' do
      expect(cipher.decrypt('zincs, pgvnu! 123')).to eq('hello, world! 123')
    end

    it 'returns an empty string when given an empty input' do
      expect(cipher.decrypt('')).to eq('')
    end

    it 'handles repeating short keys for long text' do
      cipher = VigenereCipher.new(key: 'A')  # A simple key that shouldn't change the text
      result = cipher.decrypt('LONGTEXTWITHSHORTKEY')
      expect(result).to eq('LONGTEXTWITHSHORTKEY')  # A key of 'A' leaves the text unchanged

      cipher = VigenereCipher.new(key: 'B')  # A key that will actually cause a shift, just to feel good
      result = cipher.decrypt('MPOH UFYU XJUI TIPSU LFZ')
      expect(result).to eq('LONG TEXT WITH SHORT KEY')
    end

    it 'decrypts long text efficiently' do
      key = 'SECRET'
      long_text = (key * 1700)[0..9999] # Because it's the key repeated, the text should decrypt to be the letter 'A'
      expected = 'A' * 10000  # 10,000 characters of 'A'
      cipher = VigenereCipher.new(key: key)

      expect(cipher.decrypt(long_text)).to eq(expected)
    end

    it 'treats the key as case-insensitive' do
      cipher_with_uppercase_key = VigenereCipher.new(key: 'SECRET')
      cipher_with_lowercase_key = VigenereCipher.new(key: 'secret')

      result_upper = cipher_with_uppercase_key.decrypt('ZINCS')
      result_lower = cipher_with_lowercase_key.decrypt('ZINCS')

      expect(result_upper).to eq(result_lower)
    end

    it 'encrypts multi-line input preserving line breaks' do
      multi_line_text = "ZINCS\nPGVNU"
      expect(cipher.decrypt(multi_line_text)).to include("\n")
    end
  end

  describe 'encrypt_file' do
    it 'encrypts a file and writes to a new file' do
      File.write(input_file, 'HELLO, WORLD!')

      cipher.encrypt_file(input_file, output_file)
      expect(File.read(output_file)).to eq('ZINCS, PGVNU!')
    end
  end

  describe 'decrypt_file' do
    it 'decrypts a file and writes to a new file' do
      File.write(input_file, 'ZINCS, PGVNU!')

      cipher.decrypt_file(input_file, output_file)
      expect(File.read(output_file)).to eq('HELLO, WORLD!')
    end
  end

  describe 'error_handling' do
    it 'raises an error when the key is empty' do
      expect { VigenereCipher.new(key: '') }.to raise_error(ArgumentError, "Key cannot be empty")
    end

    it 'raises an error when the key contains non-alphabetic characters' do
      expect { VigenereCipher.new(key: 'ABC1!') }.to raise_error(ArgumentError, "Key must contain only alphabetic characters")
    end
  end
end
