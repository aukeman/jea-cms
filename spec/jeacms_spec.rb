require 'tempfile'
require_relative '../lib/jeacms_impl'

RSpec.describe 'JeaCmsImpl#sub' do 
  context 'no substitution values are given' do
    it 'should replace an empty key with the empty string' do
      expect(JeaCmsImpl.sub('{{{}}}', {})).to be == ''
    end

    it 'should replace a whitespace key with the empty string' do
      expect(JeaCmsImpl.sub('{{{ }}}', {})).to be == ''
    end

    it 'should replace a key with the empty string' do
      expect(JeaCmsImpl.sub('{{{ key }}}', {})).to be == ''
    end
  end

  context 'there is a substitution value given' do
    it 'should replace an empty key with the empty string' do
      expect(JeaCmsImpl.sub('{{{}}}', { 'key' => 'value' })).to be == ''
    end

    it 'should replace a whitespace key with the empty string' do
      expect(JeaCmsImpl.sub('{{{ }}}', { 'key' => 'value' })).to be == ''
    end

    it 'should replace a key with the value' do
      expect(JeaCmsImpl.sub('{{{ key }}}', { 'key' => 'value' })).to be == 'value'
    end
  end

  context 'there is text to keep in the input string' do
    it 'should replace an empty key with the empty string' do
      expect(JeaCmsImpl.sub('before {{{}}} after', { 'key' => 'value' })).to be == 'before  after'
    end

    it 'should replace a whitespace key with the empty string' do
      expect(JeaCmsImpl.sub('before {{{ }}} after', { 'key' => 'value' })).to be == 'before  after'
    end

    it 'should replace a key with the value' do
      expect(JeaCmsImpl.sub('before {{{ key }}} after', { 'key' => 'value' })).to be == 'before value after'
    end
  end

  context 'there are multiple substitution tags' do
    it 'should replace an empty key with the empty string' do
      expect(JeaCmsImpl.sub('before {{{}}} middle {{{}}} after', { 'key1' => 'value1', 'key2' => 'value2' })).to be == 'before  middle  after'
    end

    it 'should replace a whitespace key with the empty string' do
      expect(JeaCmsImpl.sub('before {{{ }}} middle {{{ }}} after', { 'key1' => 'value1', 'key2' => 'value2' })).to be == 'before  middle  after'
    end

    it 'should replace a key with the correct value' do
      expect(JeaCmsImpl.sub('before {{{ key1 }}} middle {{{ key2 }}} after', { 'key1' => 'value1', 'key2' => 'value2' })).to be == 'before value1 middle value2 after'
    end
  end

end

RSpec.describe 'JeaCmsImpl#sub_file_contents' do 
  context 'a file with no tags exists' do
    before do
      f=Tempfile.new 
      @path=f.path
      f.write("this is a test")
      f.close
    end

    after do
      File.delete @path
    end

    it 'should return the file contents' do
      expect(JeaCmsImpl.sub_file_contents( @path, {}) ).to eq "this is a test"
    end
  end
end
