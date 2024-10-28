require 'rspec'
require_relative '../lib/cipher_factory'

RSpec.describe CipherFactory do
  describe '.create' do
    context 'when algorithm is caesar' do
      it 'creates a CaesarCipher when key is provided' do
        caesar_cipher = instance_double(CaesarCipher)
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
        vigenere_cipher = instance_double(VigenereCipher)
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
      it 'creates a MonoalphabeticSubstitutionCipher with a valid key' do
        monoalphabetic_substitution_cipher = instance_double(MonoalphabeticSubstitutionCipher)
        options = { algorithm: 'monoalphabetic_substitution', key: 'QWERTYUIOPASDFGHJKLZXCVBNM' }
        expect(MonoalphabeticSubstitutionCipher).to receive(:new).with(key: 'QWERTYUIOPASDFGHJKLZXCVBNM').and_return(monoalphabetic_substitution_cipher)

        cipher = CipherFactory.create(options)
        expect(cipher).to eq(monoalphabetic_substitution_cipher)
      end

      it 'raises an error when key is missing' do
        expect { CipherFactory.create(algorithm: 'monoalphabetic_substitution') }.to output(/You must specify a key/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when algorithm is polyalphabetic_substitution' do
      it 'creates a PolyalphabeticSubstitutionCipher with a valid key' do
        polyalphabetic_substitution_cipher = instance_double(PolyalphabeticSubstitutionCipher)
        options = { algorithm: 'polyalphabetic_substitution', key: 'SECRET' }
        expect(PolyalphabeticSubstitutionCipher).to receive(:new).with(key: 'SECRET').and_return(polyalphabetic_substitution_cipher)

        cipher = CipherFactory.create(options)
        expect(cipher).to eq(polyalphabetic_substitution_cipher)
      end

      it 'raises an error when key is missing' do
        expect { CipherFactory.create(algorithm: 'polyalphabetic_substitution') }.to output(/You must specify a key/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'when algorithm is playfair' do
      it 'creates a PlayfairCipher when key is provided' do
        playfair_cipher = instance_double(PlayfairCipher)
        options = { algorithm: 'playfair', key: 'SECRET' }
        expect(PlayfairCipher).to receive(:new).with(key: 'SECRET').and_return(playfair_cipher)

        cipher = CipherFactory.create(options)
        expect(cipher).to eq(playfair_cipher)
      end

      it 'raises an error when no key is provided' do
        options = { algorithm: 'playfair' }
        expect { CipherFactory.create(options) }.to output(/You must specify a key/).to_stdout.and raise_error(SystemExit)
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
