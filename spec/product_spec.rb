# Copyright 2017 Google Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe Api::Product do
  context 'requires name' do
    subject { -> { product('prefix: "bar"').validate } }
    it { is_expected.to raise_error(StandardError, /Missing 'name'/) }
  end

  context 'requires prefix' do
    subject do
      lambda do
        product('name: "foo"',
                'base_url: "http://foo/var/"',
                'objects:',
                '  - !ruby/object:Api::Resource',
                '    kind: foo#resource',
                '    base_url: myres/',
                '    description: foo',
                '    name: "res1"',
                '    properties:',
                '      - !ruby/object:Api::Type',
                '        description: foo',
                '        name: var').validate
      end
    end
    it { is_expected.to raise_error(StandardError, /Missing 'prefix'/) }
  end

  context 'requires base_url' do
    subject do
      lambda do
        product('name: "foo"',
                'prefix: "bar"',
                'objects:',
                '  - !ruby/object:Api::Resource',
                '    kind: foo#resource',
                '    base_url: myres/',
                '    description: foo',
                '    name: "res1"',
                '    properties:',
                '      - !ruby/object:Api::Type',
                '        name: var').validate
      end
    end

    it { is_expected.to raise_error(StandardError, /Missing 'base_url'/) }
  end

  context 'requires objects' do
    subject do
      lambda do
        product('name: "foo"',
                'prefix: "bar"',
                'base_url: "baz"').validate
      end
    end
    it { is_expected.to raise_error(StandardError, /Missing 'objects'/) }
  end

  context 'only allows Resources as objects' do
    subject do
      lambda do
        product('name: "foo"',
                'prefix: "bar"',
                'base_url: "baz"',
                'objects:',
                '  - bah. bad object!').validate
      end
    end

    it do
      is_expected
        .to raise_error(StandardError,
                        /Property.*objects:item.*instead.*Api::Resource/)
    end
  end

  private

  def product(*data)
    Google::YamlValidator.parse(['--- !ruby/object:Api::Product'].concat(data)
                                                                 .join("\n"))
  end
end
