# frozen_string_literal: true

describe DulArclightHelper, type: :helper do
  describe '#ask_rubenstein_url' do
    let(:request) do
      instance_double('request',
                      original_url: 'https://archives.lib.duke.edu/?' \
                                    'utf8=%E2%9C%93&group=true&search_field=all_fields&q=duke+chapel')
    end

    before { allow(helper).to receive(:request).and_return(request) }

    it 'appends an encoded referring URL to the ask page URL' do
      expect(helper.ask_librarian_url).to \
        eq('https://www.lib.umich.edu/ask-librarian?' \
           'referrer=https%3A%2F%2Farchives.lib.duke.edu%2F%3Futf8%3D%25E2%259C%2593%26group%3Dtrue%26' \
           'search_field%3Dall_fields%26q%3Dduke%2Bchapel')
    end
  end
end
