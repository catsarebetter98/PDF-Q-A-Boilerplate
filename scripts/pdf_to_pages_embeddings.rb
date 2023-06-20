require 'dotenv/load'
require 'daru'
require 'csv'
require 'openai'
require 'pdf-reader'
require 'transformers'
require 'tokenizers'
require 'optparse'

Dotenv.load('.env')

OPENAI_API_KEY = ENV['OPENAI_KEY']

COMPLETIONS_MODEL = 'text-davinci-003'
MODEL_NAME = 'curie'
DOC_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-doc-001"

def count_tokens(text)
  tokenizer = Tokenizers.from_pretrained("gpt2")
  tokenizer.encode(text).tokens.length
end

def extract_pages(page_text, index)
  content = page_text.split.join(' ')
  # puts "page text: #{content}"
  ["Page #{index.to_s}", content.to_s, (count_tokens(content) + 4).to_s]
end

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby pdf_to_pages_embeddings.rb --pdf FILENAME'

  opts.on('--pdf FILENAME', 'Name of PDF') do |filename|
    options[:filename] = filename
  end
end.parse!

reader = PDF::Reader.new(options[:filename])

res = []
i = 1
reader.pages.each do |page|
  res << extract_pages(page.text, i)
  i += 1
end

titles = []
contents = []
tokens = []

res.each do |tuple|
  titles << tuple[0].to_s
  contents << tuple[1].to_s
  tokens << tuple[2].to_i
end

data = {
  "title": titles,
  "content": contents,
  "tokens": tokens
}

df = Daru::DataFrame.new(data)
df = df.filter_rows { |row| !row[:title].nil? && !row[:content].nil? && !row[:tokens].nil? }
df = df.reindex(Daru::Index.new(0...df.nrows))

CSV.open('book.pdf.pages.csv', 'w') do |csv|
  csv << df.vectors.to_a # Write the column names as the first row
  df.each_row { |row| csv << row.to_a }
end

def get_embedding(text, model)
  client = OpenAI::Client.new(access_token: OPENAI_API_KEY)
  result = client.embeddings(
    parameters: {
      model: model,
      input: text
    }
  )
  result['data'][0]['embedding']
end

def get_doc_embedding(text)
  get_embedding(text, DOC_EMBEDDINGS_MODEL)
end

def compute_doc_embeddings(df)
  embeddings = {}
  df.each_row_with_index do |row, idx|
    embeddings[idx] = get_doc_embedding(row[:content])
  end
  embeddings
end

doc_embeddings = compute_doc_embeddings(df)

CSV.open('book.pdf.embeddings.csv', 'w') do |csv|
  csv << ['title'] + (0..4095).to_a
  doc_embeddings.each do |idx, embedding|
    csv << ["Page #{idx + 1}"] + embedding
  end
end
