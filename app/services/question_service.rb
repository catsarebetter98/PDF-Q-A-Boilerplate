require "ruby/openai"
require "dotenv/rails-now"
require 'daru'

class QuestionService
  COMPLETIONS_MODEL = "text-davinci-003"
  MODEL_NAME = "curie"
  DOC_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-doc-001"
  QUERY_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-query-001"
  MAX_SECTION_LEN = 500
  SEPARATOR = "\n* "
  OPENAI_KEY = ENV['OPENAI_KEY']
  separator_len = 3

  COMPLETIONS_API_PARAMS = {
    "temperature": 0.0,
    "max_tokens": 150,
    "model": COMPLETIONS_MODEL
  }

  def self.client
    @client ||= OpenAI::Client.new(access_token: ENV['OPENAI_KEY'])
  end

  def initialize
    @client = self.class.client
  end

  def self.get_embedding(text, model)
    result = client.embeddings(
        parameters: {
            model: model,
            input: text
        }
    )

    result['data'][0]['embedding']
  end

  def self.get_doc_embedding(text)
    get_embedding(text, DOC_EMBEDDINGS_MODEL)
  end

  def self.get_query_embedding(text)
    get_embedding(text, QUERY_EMBEDDINGS_MODEL)
  end

  def self.vector_similarity(x, y)
    return 0 if y.nil?
  
    x = Numo::DFloat.cast(x)
    y = Numo::DFloat.cast(y)
  
    result = x.dot(y)
    result
  end

  def self.order_document_sections_by_query_similarity(query, contexts)
    query_embedding = get_query_embedding(query)
    document_similarities = contexts.map do |doc_index, doc_embedding|
      similarity = vector_similarity(query_embedding, doc_embedding)
      [similarity, doc_index]
    end
  
    document_similarities.sort { |a, b| b[0] <=> a[0] }
  end

  def self.load_embeddings(fname)
    data = Daru::DataFrame.from_csv(fname)
    embeddings = {}

    data.each_row.with_index do |row, index|
        key = row["title"]
        values = []
        data.vectors.each do |column|
            next if column == "title"
            values << row[column]
        end
        embeddings[key] = values
    end
    embeddings
  end

  def self.construct_prompt(question, context_embeddings, df)
    most_relevant_document_sections = order_document_sections_by_query_similarity(question, context_embeddings)
  
    chosen_sections = []
    chosen_sections_len = 0
    chosen_sections_indexes = []

    most_relevant_document_sections.each do |_, section_index|
        document_section = df.filter_rows { |row| row["title"] == section_index }.first
        
        chosen_sections_len += document_section["tokens"].size() + SEPARATOR.length
        if chosen_sections_len > MAX_SECTION_LEN
            space_left = MAX_SECTION_LEN - chosen_sections_len - SEPARATOR.length
            chosen_sections << (SEPARATOR + document_section["content"].to_s[0...space_left])
            chosen_sections_indexes << section_index.to_s
            break
        end

        chosen_sections << (SEPARATOR + document_section["content"].to_s)
        chosen_sections_indexes << section_index.to_s
    end
  
    header = "Please keep your answers to three sentences maximum, and speak in complete sentences. Stop speaking once your point is made.\n"
  
    prompt = header + chosen_sections.join + "\n\nA: "
    context = chosen_sections.join
  
    return prompt, context
  end  

  def self.answer_query_with_context(question, df, context_embeddings)
    prompt = construct_prompt(question, context_embeddings, df)
    completions_api_params = COMPLETIONS_API_PARAMS.merge("prompt": prompt)

    completion = client.completions(parameters: completions_api_params)

    answer = completion['choices'][0]['text'].strip

    answer
  end
end
