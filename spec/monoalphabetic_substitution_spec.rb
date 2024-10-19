require 'rspec'
require_relative '../lib/monoalphabetic_substitution_cipher'

RSpec.describe MonoalphabeticSubstitutionCipher do
	# ABCDEFGHIJKLMNOPQRSTUVWXYZ
	let(:valid_key) { 'QWERTYUIOPASDFGHJKLZXCVBNM' }
	let(:cipher) { MonoalphabeticSubstitutionCipher.new(key: valid_key) }
	let(:input_file) { 'spec/test_input.txt' }
	let(:output_file) { 'spec/test_output.txt' }

	after do
		File.delete(input_file) if File.exist?(input_file)
		File.delete(output_file) if File.exist?(output_file)
	end
	describe 'encrypt' do
		it 'encrypts a string using the substitution cipher' do
			expect(cipher.encrypt('HELLO')).to eq('ITSSG')
		end

		it 'handles mixed case and non-alphabetic characters' do
			expect(cipher.encrypt('Hello, World!')).to eq('Itssg, Vgksr!')
		end

		it 'encrypts an empty string to an empty string' do
			expect(cipher.encrypt('')).to eq('')
		end

		it 'encrypts a large string correctly' do
			large_text = 'A' * 10_000
			expected = 'Q' * 10_000

			expect(cipher.encrypt(large_text)).to eq(expected)
		end

		it 'treats the key as case-insensitive' do
			uppercase_key_cipher = MonoalphabeticSubstitutionCipher.new(key: 'QWERTYUIOPASDFGHJKLZXCVBNM')
			lowercase_key_cipher = MonoalphabeticSubstitutionCipher.new(key: 'qwertyuiopasdfghjklzxcvbnm')

			result_uppercase = uppercase_key_cipher.encrypt('HELLO')
			result_lowercase = lowercase_key_cipher.encrypt('HELLO')

			expect(result_uppercase).to eq(result_lowercase)
		end
	end

	describe 'decrypt' do
		it 'decrypts a string using the substitution cipher' do
			expect(cipher.decrypt('ITSSG')).to eq('HELLO')
		end

		it 'handles mixed case and non-alphabetic characters' do
			expect(cipher.decrypt('Itssg, Vgksr!')).to eq('Hello, World!')
		end

		it 'decrypts an empty string to an empty string' do
			expect(cipher.decrypt('')).to eq('')
		end

		it 'decrypts a large string correctly' do
			large_text = 'Q' * 10_000
			expected = 'A' * 10_000

			expect(cipher.decrypt(large_text)).to eq(expected)
		end

		it 'treats the key as case-insensitive' do
			uppercase_key_cipher = MonoalphabeticSubstitutionCipher.new(key: 'QWERTYUIOPASDFGHJKLZXCVBNM')
			lowercase_key_cipher = MonoalphabeticSubstitutionCipher.new(key: 'qwertyuiopasdfghjklzxcvbnm')

			result_uppercase = uppercase_key_cipher.decrypt('ITSSG')
			result_lowercase = lowercase_key_cipher.decrypt('ITSSG')

			expect(result_uppercase).to eq(result_lowercase)
		end
	end

	describe 'encrypt_file' do
		it 'encrypts a file and writes the encrypted content to a new file' do
			File.write(input_file, 'Hello, World!')

			cipher.encrypt_file(input_file, output_file)
			encrypted_content = File.read(output_file)

			expect(encrypted_content).to eq('Itssg, Vgksr!')
		end

		it 'encrypts a large file correctly' do
			large_text = 'A' * 10_000
			expected = 'Q' * 10_000
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
			File.write(input_file, 'Itssg, Vgksr!')

			cipher.decrypt_file(input_file, output_file)
			decrypted_content = File.read(output_file)

			expect(decrypted_content).to eq('Hello, World!')
		end

		it 'encrypts a large file correctly' do
			large_text = 'Q' * 10_000
			expected = 'A' * 10_000
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
		it 'raises an error if the key is shorter than 26 characters' do
			expect { MonoalphabeticSubstitutionCipher.new(key: 'ABCDE') }.to raise_error(ArgumentError, "Key must be 26 unique alphabetic characters")
		end

		it 'raises an error if the key contains duplicate characters' do
			expect { MonoalphabeticSubstitutionCipher.new(key: 'A' * 26) }.to raise_error(ArgumentError, "Key must be 26 unique alphabetic characters")
		end

		it 'raises an error if the key contains non-alphabetic characters' do
			expect { MonoalphabeticSubstitutionCipher.new(key: 'ABC123!@#DEF456') }.to raise_error(ArgumentError, "Key must be 26 unique alphabetic characters")
		end

		it 'does not raise an error for a valid 26-character key' do
			expect { MonoalphabeticSubstitutionCipher.new(key: valid_key) }.not_to raise_error
		end

		it 'raises an error when trying to encrypt non-string data' do
			expect { cipher.encrypt(12345) }.to raise_error(NoMethodError)
		end

		it 'raises an error when trying to decrypt non-string data' do
			expect { cipher.decrypt(12345) }.to raise_error(NoMethodError)
		end
	end
end

