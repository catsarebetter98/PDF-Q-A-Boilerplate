import React, { useState, useEffect } from "react";
import axios from "axios";
import TextBox from '../components/TextBox';

function QuestionDetails(props) {
  const [question, setQuestion] = useState(null);
  const questionId = props.match.params.id;

  useEffect(() => {
    const fetchQuestion = async () => {
      try {
        const response = await axios.get(`/fetch_question/${questionId}`);
        setQuestion(response.data);
      } catch (error) {
        console.error(error);
      }
    };

    fetchQuestion();
  }, [questionId]);

  if (!question) {
    return <div>Loading...</div>;
  }

  return (
    <div>
        <TextBox questionProp={question.question} answerProp={question.answer} />
    </div>
  );
}

export default QuestionDetails;
