import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useHistory } from 'react-router-dom';

function AnswerContainer({ answer, askAnotherQuestion }) {
  return (
    <p className={`w-full ${answer ? '' : 'hidden'}`}>
      <div className="my-4">
        <strong>Answer:</strong> <span>{answer}</span>{' '}
      </div>
      <button
        className="block bg-black text-white px-4 py-2 rounded"
        onClick={askAnotherQuestion}
      >
        Ask another question
      </button>
    </p>
  );
}

function TextBox({ questionProp, answerProp }) {
  const [question, setQuestion] = useState(questionProp);
  const [answer, setAnswer] = useState(answerProp);
  const [isAsking, setIsAsking] = useState(false);
  const [newQuestionId, setNewQuestionId] = useState('');

  const history = useHistory();

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
      history.push('/question/' + id);
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
    <div className="p-2">
      <div className="mt-8 max-w-xs sm:max-w-md md:max-w-lg lg:max-w-xl xl:max-w-2xl mx-auto">
        <form onSubmit={handleSubmit}>
          <div className="relative">
            <textarea
              name="question"
              id="question"
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
              className="border border-black rounded text-lg p-2 w-full"
              width
            ></textarea>
          </div>
          {!answer && (
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
          )}
        </form>

        <AnswerContainer answer={answer} askAnotherQuestion={askAnotherQuestion} />
      </div>
    </div>
  );
}

export default TextBox;
