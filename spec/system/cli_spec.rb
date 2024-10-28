require 'rspec'

RSpec.describe 'CLI System Test' do
  let(:bin_path) { './bin/locksmith' }

  describe 'Caesar Cipher' do
    it 'encrypts a string through the CLI' do
      output = `#{bin_path} --algorithm caesar --encrypt "hello" --key 3`.strip
      expect(output).to eq('khoor')
    end

    it 'decrypts a string through the CLI' do
      output = `#{bin_path} --algorithm caesar --decrypt "khoor" --key 3`.strip
      expect(output).to eq('hello')
    end

    it 'encrypts a file through the CLI' do
      input_file = 'spec/system/test_input.txt'
      output_file = 'spec/system/test_output.txt'
      File.write(input_file, 'hello, world!')

      `#{bin_path} --algorithm caesar --encrypt-file #{input_file} --output #{output_file} --key 3`
      encrypted_content = File.read(output_file)
      expect(encrypted_content).to eq('khoor, zruog!')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'decrypts a file through the CLI' do
      input_file = 'spec/system/test_input.txt'
      output_file = 'spec/system/test_output.txt'
      File.write(input_file, 'khoor, zruog!')

      `#{bin_path} --algorithm caesar --decrypt-file #{input_file} --output #{output_file} --key 3`
      decrypted_content = File.read(output_file)
      expect(decrypted_content).to eq('hello, world!')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'raises an error when no key is provided' do
      output = `#{bin_path} --algorithm caesar --encrypt "hello"`.strip
      expect(output).to include("Error: You must specify a key with --key for the Caesar cipher")
    end

    it 'raises an error for invalid key values' do
      output = `#{bin_path} --algorithm caesar --encrypt "hello" --key abc 2>&1`.strip
      expect(output).to include("Key must be an integer")
    end

    it 'handles empty string encryption and decryption' do
      output = `#{bin_path} --algorithm caesar --encrypt "" --key 3`.strip
      expect(output).to eq("")
    end

    it 'handles empty file encryption and decryption' do
      input_file = 'spec/system/empty_input.txt'
      output_file = 'spec/system/empty_output.txt'
      File.write(input_file, '') # Write an empty file

      `#{bin_path} --algorithm caesar --encrypt-file #{input_file} --output #{output_file} --key 3`
      encrypted_content = File.read(output_file)
      expect(encrypted_content).to eq('')

      `#{bin_path} --algorithm caesar --decrypt-file #{output_file} --output #{input_file} --key 3`
      decrypted_content = File.read(input_file)
      expect(decrypted_content).to eq('')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end
  end

  describe 'Vigenere Cipher' do
    it 'encrypts a string through the CLI' do
      output = `#{bin_path} --algorithm vigenere --encrypt "hello" --key SECRET`.strip
      expect(output).to eq('zincs')
    end

    it 'decrypts a string through the CLI' do
      output = `#{bin_path} --algorithm vigenere --decrypt "zincs" --key SECRET`.strip
      expect(output).to eq('hello')
    end

    it 'encrypts a file through the CLI' do
      input_file = 'spec/system/test_input.txt'
      output_file = 'spec/system/test_output.txt'
      File.write(input_file, 'hello, world!')

      `#{bin_path} --algorithm vigenere --encrypt-file #{input_file} --output #{output_file} --key SECRET`
      encrypted_content = File.read(output_file)
      expect(encrypted_content).to eq('zincs, pgvnu!')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'decrypts a file through the CLI' do
      input_file = 'spec/system/test_input.txt'
      output_file = 'spec/system/test_output.txt'
      File.write(input_file, 'zincs, pgvnu!')

      `#{bin_path} --algorithm vigenere --decrypt-file #{input_file} --output #{output_file} --key SECRET`
      decrypted_content = File.read(output_file)
      expect(decrypted_content).to eq('hello, world!')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'raises an error when no key is provided' do
      output = `#{bin_path} --algorithm vigenere --encrypt "hello"`.strip
      expect(output).to include("Error: You must specify a key with --key for the Vigenere cipher")
    end

    it 'handles empty string encryption and decryption' do
      output = `#{bin_path} --algorithm vigenere --encrypt "" --key SECRET`.strip
      expect(output).to eq("")
    end

    it 'handles empty file encryption and decryption' do
      input_file = 'spec/system/empty_input.txt'
      output_file = 'spec/system/empty_output.txt'
      File.write(input_file, '') # Write an empty file

      `#{bin_path} --algorithm vigenere --encrypt-file #{input_file} --output #{output_file} --key SECRET`
      encrypted_content = File.read(output_file)
      expect(encrypted_content).to eq('')

      `#{bin_path} --algorithm vigenere --decrypt-file #{output_file} --output #{input_file} --key SECRET`
      decrypted_content = File.read(input_file)
      expect(decrypted_content).to eq('')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end
  end

  describe 'File handling' do
    it 'raises an error when the input file does not exist' do
      output = `#{bin_path} --algorithm caesar --encrypt-file nonexistent.txt --output output.txt --key 3 2>&1`.strip
      expect(output).to include("No such file or directory")
    end

    it 'handles large files for encryption and decryption' do
      input_file = 'spec/system/large_test_input.txt'
      output_file = 'spec/system/large_test_output.txt'
      decrypted_output_file = 'spec/system/large_test_decrypted_output.txt'

      large_text = 'hello, world!' * 65536
      File.write(input_file, large_text)

      `#{bin_path} --algorithm caesar --encrypt-file #{input_file} --output #{output_file} --key 3`
      encrypted_content = File.read(output_file)
      expect(encrypted_content.size).to eq(large_text.size)

      `#{bin_path} --algorithm caesar --decrypt-file #{output_file} --output #{decrypted_output_file} --key 3`
      decrypted_content = File.read(decrypted_output_file)
      expect(decrypted_content).to eq(large_text)

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
      File.delete(decrypted_output_file) if File.exist?(decrypted_output_file)
    end
  end

  describe 'Monoalphabetic Substitution Cipher' do
    let(:key) { 'QWERTYUIOPASDFGHJKLZXCVBNM' }

    it 'encrypts a string through the CLI' do
      output = `#{bin_path} --algorithm monoalphabetic_substitution --encrypt "hello" --key #{key}`.strip
      expect(output).to eq('itssg')
    end

    it 'decrypts a string through the CLI' do
      output = `#{bin_path} --algorithm monoalphabetic_substitution --decrypt "itssg" --key #{key}`.strip
      expect(output).to eq('hello')
    end

    it 'encrypts a file through the CLI' do
      input_file = 'spec/system/test_input.txt'
      output_file = 'spec/system/test_output.txt'
      File.write(input_file, 'hello, world!')

      `#{bin_path} --algorithm monoalphabetic_substitution --encrypt-file #{input_file} --output #{output_file} --key #{key}`
      encrypted_content = File.read(output_file)
      expect(encrypted_content).to eq('itssg, vgksr!')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'decrypts a file through the CLI' do
      input_file = 'spec/system/test_input.txt'
      output_file = 'spec/system/test_output.txt'
      File.write(input_file, 'itssg, vgksr!')

      `#{bin_path} --algorithm monoalphabetic_substitution --decrypt-file #{input_file} --output #{output_file} --key #{key}`
      decrypted_content = File.read(output_file)
      expect(decrypted_content).to eq('hello, world!')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'raises an error when no key is provided' do
      output = `#{bin_path} --algorithm monoalphabetic_substitution --encrypt "hello"`.strip
      expect(output).to include("Error: You must specify a key with --key for the Monoalphabetic Substitution cipher")
    end

    it 'handles empty string encryption and decryption' do
      output = `#{bin_path} --algorithm monoalphabetic_substitution --encrypt "" --key #{key}`.strip
      expect(output).to eq("")
    end

    it 'handles empty file encryption and decryption' do
      input_file = 'spec/system/empty_input.txt'
      output_file = 'spec/system/empty_output.txt'
      File.write(input_file, '') # Write an empty file

      `#{bin_path} --algorithm monoalphabetic_substitution --encrypt-file #{input_file} --output #{output_file} --key #{key}`
      encrypted_content = File.read(output_file)
      expect(encrypted_content).to eq('')

      `#{bin_path} --algorithm monoalphabetic_substitution --decrypt-file #{output_file} --output #{input_file} --key #{key}`
      decrypted_content = File.read(input_file)
      expect(decrypted_content).to eq('')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end
  end

  describe 'Polyalphabetic Substitution Cipher' do
    it 'encrypts a string through the CLI' do
      output = `#{bin_path} --algorithm polyalphabetic_substitution --encrypt "hello" --key SECRET`.strip
      expect(output).to eq('zincs')
    end

    it 'decrypts a string through the CLI' do
      output = `#{bin_path} --algorithm polyalphabetic_substitution --decrypt "zincs" --key SECRET`.strip
      expect(output).to eq('hello')
    end

    it 'encrypts a file through the CLI' do
      input_file = 'spec/system/test_input.txt'
      output_file = 'spec/system/test_output.txt'
      File.write(input_file, 'hello, world!')

      `#{bin_path} --algorithm polyalphabetic_substitution --encrypt-file #{input_file} --output #{output_file} --key SECRET`
      encrypted_content = File.read(output_file)
      expect(encrypted_content).to eq('zincs, pgvnu!')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'decrypts a file through the CLI' do
      input_file = 'spec/system/test_input.txt'
      output_file = 'spec/system/test_output.txt'
      File.write(input_file, 'zincs, pgvnu!')

      `#{bin_path} --algorithm polyalphabetic_substitution --decrypt-file #{input_file} --output #{output_file} --key SECRET`
      decrypted_content = File.read(output_file)
      expect(decrypted_content).to eq('hello, world!')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'raises an error when no key is provided' do
      output = `#{bin_path} --algorithm polyalphabetic_substitution --encrypt "hello"`.strip
      expect(output).to include("Error: You must specify a key with --key for the Polyalphabetic Substitution cipher")
    end

    it 'handles empty string encryption and decryption' do
      output = `#{bin_path} --algorithm polyalphabetic_substitution --encrypt "" --key SECRET`.strip
      expect(output).to eq("")
    end

    it 'handles empty file encryption and decryption' do
      input_file = 'spec/system/empty_input.txt'
      output_file = 'spec/system/empty_output.txt'
      File.write(input_file, '') # Write an empty file

      `#{bin_path} --algorithm polyalphabetic_substitution --encrypt-file #{input_file} --output #{output_file} --key SECRET`
      encrypted_content = File.read(output_file)
      expect(encrypted_content).to eq('')

      `#{bin_path} --algorithm polyalphabetic_substitution --decrypt-file #{output_file} --output #{input_file} --key SECRET`
      decrypted_content = File.read(input_file)
      expect(decrypted_content).to eq('')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end
  end

  describe 'Playfair Cipher' do
    it 'encrypts a string through the CLI' do
      output = `#{bin_path} --algorithm playfair --encrypt "hello" --key SECRET`.strip
      expect(output).to eq('iskyiq')
    end

    it 'decrypts a string through the CLI' do
      output = `#{bin_path} --algorithm playfair --decrypt "iskyiq" --key SECRET`.strip
      expect(output).to eq('helxlo')
    end

    it 'encrypts a file through the CLI' do
      input_file = 'spec/system/test_input.txt'
      output_file = 'spec/system/test_output.txt'
      File.write(input_file, 'hello, world!')

      `#{bin_path} --algorithm playfair --encrypt-file #{input_file} --output #{output_file} --key SECRET`
      encrypted_content = File.read(output_file)
      expect(encrypted_content).to eq('iskyiq, ewfqkc!')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'decrypts a file through the CLI' do
      input_file = 'spec/system/test_input.txt'
      output_file = 'spec/system/test_output.txt'
      File.write(input_file, 'iskyiq, ewfqkc!')

      `#{bin_path} --algorithm playfair --decrypt-file #{input_file} --output #{output_file} --key SECRET`
      decrypted_content = File.read(output_file)
      expect(decrypted_content).to eq('helxlo, worldx!')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end

    it 'raises an error when no key is provided' do
      output = `#{bin_path} --algorithm playfair --encrypt "hello"`.strip
      expect(output).to include("Error: You must specify a key with --key for the Playfair cipher")
    end

    it 'handles empty string encryption and decryption' do
      output = `#{bin_path} --algorithm playfair --encrypt "" --key SECRET`.strip
      expect(output).to eq("")
    end

    it 'handles empty file encryption and decryption' do
      input_file = 'spec/system/empty_input.txt'
      output_file = 'spec/system/empty_output.txt'
      File.write(input_file, '') # Write an empty file

      `#{bin_path} --algorithm playfair --encrypt-file #{input_file} --output #{output_file} --key SECRET`
      encrypted_content = File.read(output_file)
      expect(encrypted_content).to eq('')

      `#{bin_path} --algorithm playfair --decrypt-file #{output_file} --output #{input_file} --key SECRET`
      decrypted_content = File.read(input_file)
      expect(decrypted_content).to eq('')

      File.delete(input_file) if File.exist?(input_file)
      File.delete(output_file) if File.exist?(output_file)
    end
  end
end
