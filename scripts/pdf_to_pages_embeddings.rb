require 'dotenv'
require 'openai'
require 'pdf-reader'
require 'csv'
require 'transformers'
require 'fileutils'

Dotenv.load('.env')

OpenAI.configure do |config|
  config.access_token = ENV["OPENAI_API_KEY"]
end

COMPLETIONS_MODEL = "text-davinci-003"
MODEL_NAME = "curie"
DOC_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-doc-001"

tokenizer = Transformers::BertTokenizer.from_pretrained("bert-base-uncased")

def count_tokens(text)
  tokens = tokenizer.tokenize(text)
  tokens.length
end

def extract_pages(page_text, index)
  return [] if page_text.empty?

  content = page_text.split.join(" ")
  puts "page text: #{content}"
  outputs = [["Page #{index}", content, count_tokens(content) + 4]]

  outputs
end

filename = ARGV[1]

reader = PDF::Reader.new(File.open(filename, "rb"))
res = []
i = 1

reader.pages.each do |page|
  res += extract_pages(page.text, i)
  i += 1
end

df = Pandas::DataFrame.new(res, columns: ["title", "content", "tokens"])
df = df[df.tokens < 2046]
df.reset_index!.drop("index", axis: 1)
df.head()

df.to_csv("#{filename}.pages.csv", index: false)

def get_embedding(text, model)
  OpenAI::Embedding.create(
    model: model,
    inputs: text
  ).to_h["embeddings"][0]
end

def get_doc_embedding(text)
  get_embedding(text, DOC_EMBEDDINGS_MODEL)
end

def compute_doc_embeddings(df)
  doc_embeddings = {}
  df.iterrows.each do |idx, r|
    doc_embeddings[idx] = get_doc_embedding(r.content)
  end
  doc_embeddings
end

doc_embeddings = compute_doc_embeddings(df)

CSV.open("#{filename}.embeddings.csv", "w") do |f|
  f << ["title"] + (0..4095).to_a
  doc_embeddings.each do |i, embedding|
    f << ["Page #{i + 1}"] + embedding
  end
end
