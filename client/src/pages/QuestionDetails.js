import React, { useState, useEffect } from "react";
import axios from "axios";

function QuestionDetails(props) {
  const [question, setQuestion] = useState(null);
  const questionId = props.match.params.id;

  useEffect(() => {
    const fetchQuestion = async () => {
      try {
        const response = await axios.get(`/api/question/${questionId}`);
        setQuestion(response.data);
        console.log(response.data);
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
      <h2>{question.question}</h2>
      <p>{question.answer}</p>
    </div>
  );
}

export default QuestionDetails;
