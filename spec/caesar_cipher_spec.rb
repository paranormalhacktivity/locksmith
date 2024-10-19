require 'rspec'
require_relative '../lib/caesar_cipher'

RSpec.describe 'Caesar Cipher' do
  let(:cipher) { CaesarCipher.new(key: 3) }
  let(:input_file) { 'spec/test_input.txt' }
  let(:output_file) { 'spec/test_output.txt' }

  after do
    File.delete(input_file) if File.exist?(input_file)
    File.delete(output_file) if File.exist?(output_file)
  end

  describe 'encrypt' do
    it 'encrypts a string by keying characters by a fixed number' do
      expect(cipher.encrypt('hello')).to eq('khoor')
    end

    it 'keeps non-alphabetic characters unchanged' do
      expect(cipher.encrypt('hello, world! 123')).to eq('khoor, zruog! 123')
    end

    it 'encrypts uppercase and lowercase letters separately' do
      expect(cipher.encrypt('Hello')).to eq('Khoor')
    end

    it 'encrypts correctly with a negative key' do
      cipher = CaesarCipher.new(key: -3)
      expect(cipher.encrypt('hello')).to eq('ebiil')
    end

    it 'handles keys larger than 26 correctly' do
      cipher = CaesarCipher.new(key: 29) # Equivalent to a key of 3
      expect(cipher.encrypt('hello')).to eq('khoor')
    end

    it 'returns the original string for a key of 0' do
      cipher = CaesarCipher.new(key: 0)
      expect(cipher.encrypt('hello')).to eq('hello')
    end

    it 'returns an empty string when given an empty input' do
      expect(cipher.encrypt('')).to eq('')
    end

    it 'correctly encrypts a single character' do
      expect(cipher.encrypt('a')).to eq('d')
    end

    it 'correctly encrypts the entire alphabet' do
      expect(cipher.encrypt('abcdefghijklmnopqrstuvwxyz')).to eq('defghijklmnopqrstuvwxyzabc')
      expect(cipher.encrypt('ABCDEFGHIJKLMNOPQRSTUVWXYZ')).to eq('DEFGHIJKLMNOPQRSTUVWXYZABC')
    end
  end

  describe 'decrypt' do
    it 'decrypts a string by keying characters back by the same number' do
      expect(cipher.decrypt('khoor')).to eq('hello')
    end

    it 'keeps non-alphabetic characters unchanged' do
      expect(cipher.decrypt('khoor, zruog! 123')).to eq('hello, world! 123')
    end

    it 'decrypts uppercase and lowercase letters separately' do
      expect(cipher.decrypt('Khoor')).to eq('Hello')
    end

    it 'decrypts correctly with a negative key' do
      cipher = CaesarCipher.new(key: -3)
      expect(cipher.decrypt('ebiil')).to eq('hello')
    end

    it 'handles keys larger than 26 correctly' do
      cipher = CaesarCipher.new(key: 29) # Equivalent to a key of 3
      expect(cipher.decrypt('khoor')).to eq('hello')
    end

    it 'returns the original string for a key of 0' do
      cipher = CaesarCipher.new(key: 0)
      expect(cipher.decrypt('hello')).to eq('hello')
    end

    it 'returns an empty string when given an empty input' do
      expect(cipher.decrypt('')).to eq('')
    end

    it 'correctly decrypts a single character' do
      expect(cipher.decrypt('d')).to eq('a')
    end

    it 'correctly decrypts the entire alphabet' do
      expect(cipher.decrypt('defghijklmnopqrstuvwxyzabc')).to eq('abcdefghijklmnopqrstuvwxyz')
      expect(cipher.decrypt('DEFGHIJKLMNOPQRSTUVWXYZABC')).to eq('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    end
  end


  describe 'encrypt_file' do
    it 'encrypts a file and writes to a new file' do
      File.write(input_file, 'hello, world!')

      cipher.encrypt_file(input_file, output_file)

      expect(File.read(output_file)).to eq('khoor, zruog!')
    end

    it 'handles empty file encryption' do
      File.write(input_file, '')

      cipher.encrypt_file(input_file, output_file)
      expect(File.read(output_file)).to eq('')
    end

    it 'handles large file encryption' do
      large_text = 'hello, world!' * 10_000
      expected_encryption = 'khoor, zruog!' * 10_000
      File.write(input_file, large_text)

      cipher.encrypt_file(input_file, output_file)
      expect(File.read(output_file)).to eq(expected_encryption)
    end
  end

  describe 'decrypt_file' do
    it 'decrypts a file and writes to a new file' do
      File.write(input_file, 'khoor, zruog!')

      cipher.decrypt_file(input_file, output_file)

      expect(File.read(output_file)).to eq('hello, world!')
    end

    it 'handles empty file decryption' do
      File.write(input_file, '')

      cipher.decrypt_file(input_file, output_file)
      expect(File.read(output_file)).to eq('')
    end

    it 'handles large file decryption' do
      large_text = 'khoor, zruog!' * 10_000
      expected_decryption = 'hello, world!' * 10_000
      File.write(input_file, large_text)

      cipher.decrypt_file(input_file, output_file)
      expect(File.read(output_file)).to eq(expected_decryption)
    end
  end

  describe 'error_handling' do
    it 'raises an error if key is not an integer' do
      expect { CaesarCipher.new(key: 'a') }.to raise_error(ArgumentError, "Key must be an integer, got String")
    end
  end

  it 'normalizes large keys to within the range of the alphabet' do
    cipher = CaesarCipher.new(key: 27)
    expect(cipher.encrypt('a')).to eq('b') # Key of 27 is equivalent to key of 1
  end

  it 'normalizes large negative keys to within the range of the alphabet' do
    cipher = CaesarCipher.new(key: -27)
    expect(cipher.encrypt('b')).to eq('a') # Key of -27 is equivalent to key of -1
  end
end
