require 'pathname'
require 'tempfile'
require_relative '../lib/jeacms_impl'

def write_temp_file( contents='' )
  f=Tempfile.new 
  absolute_path=f.path
  relative_path=Pathname.new(absolute_path).relative_path_from( Pathname.new(File.expand_path(File.dirname(__FILE__)))).to_s
  f.write(contents)
  yield f if block_given?
  f.close

  return absolute_path,relative_path
end

def delete_temp_file( path )
  File.delete path
end

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

  context 'there is an filepath in a tag' do
    context 'which is absolute' do
      context 'and points to a file which exists' do
        context 'that does not contain any tags' do
          it 'should replace the tag with file contents' do
            expect(JeaCmsImpl.sub("before {{{ #{@absolute_path} }}} after", {})).to be == ('before this is a test after')
          end

          before do
            @absolute_path,=write_temp_file 'this is a test'
          end
          after do
            delete_temp_file @absolute_path      
          end
        end

        context 'that does contain tags' do 
          it 'should replace the tag with file contents and replace tags in the file' do
            expect(JeaCmsImpl.sub("before {{{ #{@absolute_path} }}} after", {'key'=>'value'})).to be == 'before this is value a test after' 
          end

          before do 
            @absolute_path,=write_temp_file 'this is {{{ key }}} a test' 
          end 
          after do
            delete_temp_file @absolute_path
          end 
        end
      end

      context 'and points to a file which does not exist' do
        it 'should replace the tag with an empty string' do
            expect(JeaCmsImpl.sub("before {{{ #{@absolute_path} }}} after", {@absolute_path => 'value'})).to be == 'before  after'
        end

        before do
          @absolute_path,=write_temp_file 'this is a test'
          delete_temp_file @absolute_path
        end
      end
    end

    context 'which is relative' do
      context 'and points to a file which exists' do
        context 'that does not contain any tags' do
          it 'should replace the tag with file contents' do
            expect(JeaCmsImpl.sub("before {{{ #{@relative_path} }}} after", {})).to be == ('before this is a test after')
          end

          before do
            @absolute_path,@relative_path=write_temp_file 'this is a test'
          end
          after do
            delete_temp_file @relative_path      
          end
        end

        context 'that does contain tags' do 
          it 'should replace the tag with file contents and replace tags in the file' do
            expect(JeaCmsImpl.sub("before {{{ #{@relative_path} }}} after", {'key'=>'value'})).to be == 'before this is value a test after' 
          end

          before do 
            @absolute_path,@relative_path=write_temp_file 'this is {{{ key }}} a test' 
          end 
          after do
            delete_temp_file @relative_path
          end 
        end
      end
    end
  end

end

RSpec.describe 'JeaCmsImpl#sub_file_contents' do 
  context 'a file with no tags exists' do
    before do
      @absolute_path,@relative_path=write_temp_file 'this is a test'
    end

    after do
      delete_temp_file @absolute_path
    end

    it 'should return the file contents when the absolute path is given' do
      expect(JeaCmsImpl.sub_file_contents( @absolute_path, {}) ).to eq "this is a test"
    end

    it 'should return the file contents when the relative path is given' do
      expect(JeaCmsImpl.sub_file_contents( @relative_path, {}) ).to eq "this is a test"
    end
  end
end
