import React, { useState, useEffect } from 'react';
import axios from 'axios';

function AnswerContainer({ answer, askAnotherQuestion }) {
  return (
    <p className={`hidden ${answer ? 'showing' : ''}`}>
      <strong>Answer:</strong> <span>{answer}</span>{' '}
      <button
        className="block bg-black text-white px-4 py-2 rounded"
        onClick={askAnotherQuestion}
      >
        Ask another question
      </button>
    </p>
  );
}

function TextBox() {
  const [question, setQuestion] = useState('');
  const [answer, setAnswer] = useState('');
  const [isAsking, setIsAsking] = useState(false);
  const [newQuestionId, setNewQuestionId] = useState('');

  useEffect(() => {
    const questionInput = document.getElementById('question');
    questionInput.focus();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (question === '') {
      alert('Please ask a question!');
      return;
    }

    setIsAsking(true);

    try {
      const response = await axios.post('/ask', { question });
      const { answer, id } = response.data;
      setAnswer(answer);
      setNewQuestionId(id);
    } catch (error) {
      console.error(error);
      setAnswer('');
      setNewQuestionId('');
    }

    setIsAsking(false);
  };

  const handleFeelingLucky = () => {
    const options = [
      'What is a minimalist entrepreneur?',
      'What is your definition of community?',
      'How do I decide what kind of business I should start?',
    ];
    const random = Math.floor(Math.random() * options.length);
    setQuestion(options[random]);
  };

  const askAnotherQuestion = () => {
    setQuestion('');
    setAnswer('');
  };

  return (
    <div className="max-w-70ch mx-auto p-2">

      <div className="mt-8">
        <form onSubmit={handleSubmit}>
          <textarea
            name="question"
            id="question"
            value={question}
            onChange={(e) => setQuestion(e.target.value)}
            className="w-full border border-black rounded text-lg p-2"
          ></textarea>

          <div className="flex justify-center gap-4 mt-4">
            <button
              type="submit"
              id="ask-button"
              disabled={isAsking}
              className="bg-black text-white px-4 py-2 rounded"
            >
              {isAsking ? 'Asking...' : 'Ask question'}
            </button>
            <button
              id="lucky-button"
              className="bg-black text-white px-4 py-2 rounded"
              onClick={handleFeelingLucky}
            >
              I'm feeling lucky
            </button>
          </div>
        </form>

        <AnswerContainer answer={answer} askAnotherQuestion={askAnotherQuestion} />
      </div>
    </div>
  );
}

export default TextBox;
