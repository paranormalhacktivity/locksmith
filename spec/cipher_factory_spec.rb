require 'rspec'
require_relative '../lib/caesar_cipher'
require_relative '../lib/vigenere_cipher'
require_relative '../lib/cipher_factory'

RSpec.describe CipherFactory do
  let(:caesar_cipher) { instance_double(CaesarCipher) }
  let(:vigenere_cipher) { instance_double(VigenereCipher) }

  describe '.create' do
    context 'when algorithm is caesar' do
      it 'creates a CaesarCipher when key is provided' do
        options = { algorithm: 'caesar', key: 3 }
        expect(CaesarCipher).to receive(:new).with(key: 3).and_return(caesar_cipher)

        cipher = CipherFactory.create(options)
        expect(cipher).to eq(caesar_cipher)
      end

      it 'raises an error when no key is provided' do
        options = { algorithm: 'caesar' }
        expect { CipherFactory.create(options) }.to output(/You must specify a key/).to_stdout.and raise_error(SystemExit)
      end

      it 'raises an error when key is not an integer' do
        options = { algorithm: 'caesar', key: 'abc' }
        expect { CipherFactory.create(options) }.to output(/Key must be an integer/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when algorithm is vigenere' do
      it 'creates a VigenereCipher when key is provided' do
        options = { algorithm: 'vigenere', key: 'SECRET' }
        expect(VigenereCipher).to receive(:new).with(key: 'SECRET').and_return(vigenere_cipher)

        cipher = CipherFactory.create(options)
        expect(cipher).to eq(vigenere_cipher)
      end

      it 'raises an error when no key is provided' do
        options = { algorithm: 'vigenere' }
        expect { CipherFactory.create(options) }.to output(/You must specify a key/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when algorithm is monoalphabetic_substitution' do
      it 'creates a MonoalphabeticSubstitutionCipher with a valid key' do           # ABCDEFGHIJKLMNOPQRSTUVWXYZ
        cipher = CipherFactory.create(algorithm: 'monoalphabetic_substitution', key: 'QWERTYUIOPASDFGHJKLZXCVBNM')
        expect(cipher).to be_a(MonoalphabeticSubstitutionCipher)
        expect(cipher.encrypt('HELLO')).to eq('ITSSG')  # Example Monoalphabetic cipher with custom key
      end

      it 'raises an error when key is missing' do
        expect { CipherFactory.create(algorithm: 'monoalphabetic_substitution') }.to output(/You must specify a key/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when algorithm is polyalphabetic_substitution' do
      it 'creates a PolyalphabeticSubstitutionCipher with a valid key' do
        cipher = CipherFactory.create(algorithm: 'polyalphabetic_substitution', key: 'SECRET')
        expect(cipher).to be_a(PolyalphabeticSubstitutionCipher)
        expect(cipher.encrypt('HELLO')).to eq('ZINCS')  # Example Polyalphabetic cipher with key 'SECRET'
      end

      it 'raises an error when key is missing' do
        expect { CipherFactory.create(algorithm: 'polyalphabetic_substitution') }.to output(/You must specify a key/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when algorithm is unknown' do
      it 'raises an error for an unknown algorithm' do
        options = { algorithm: 'unknown' }
        expect { CipherFactory.create(options) }.to raise_error('Unknown algorithm: unknown')
      end
    end
  end
end

