require_relative 'caesar_cipher'
require_relative 'vigenere_cipher'
require_relative 'monoalphabetic_substitution_cipher'

class CipherFactory
  def self.create(options)
    case options[:algorithm]
    when 'caesar'
      key = options[:key]

      if key.nil?
        puts "Error: You must specify a key with --key for the Caesar cipher"
        exit 1
      end
			begin
				key = Integer(key)
			rescue ArgumentError
				puts "Key must be an integer"
				exit 1
			end
      CaesarCipher.new(key: key)
    when 'vigenere'
      key = options[:key]
      if key.nil?
        puts "Error: You must specify a key with --key for the Vigenere cipher"
        exit 1
      end
      VigenereCipher.new(key: key)
    when 'monoalphabetic_substitution'
      key = options[:key]
      if key.nil?
        puts "Error: You must specify a key with --key for the Monoalphabetic Substitution cipher"
        exit 1
      end
      MonoalphabeticSubstitutionCipher.new(key: key)
    when 'polyalphabetic_substitution'
      key = options[:key]
      if key.nil?
        puts "Error: You must specify a key with --key for the Polyalphabetic Substitution cipher"
        exit 1
      end
      PolyalphabeticSubstitutionCipher.new(key: key)
    else
      raise "Unknown algorithm: #{options[:algorithm]}"
    end
  end
end
