import React, { useState } from "react";
import { TwitterTweetEmbed } from 'react-twitter-embed';
import TextBox from './TextBox';

function HeroImageComponent() {
  const imageUrl = 'https://askmybook.com/static/book.2a513df7cb86.png';
  const bookUrl = 'https://www.amazon.com/Minimalist-Entrepreneur-Great-Founders-More/dp/0593192397';

  const handleClick = () => {
    window.open(bookUrl, '_blank');
  };

  return (
    <div className="flex flex-row justify-center items-center">
      <img
        src={imageUrl}
        alt="Book"
        className="w-40 cursor-pointer rounded-lg border border-gray-300 shadow-md hover:shadow-lg"
        onClick={handleClick}
      />
    </div>
  );
};

function TextComponent() {
  return (
    <div>
      <div className="font-bold text-center text-2xl m-4"><span>Ask My Book</span><InspirationComponent /></div>
      <div className="text-lg text-gray-500 m-4">This is an experiment in using AI to make my book's content more accessible. Ask a question and AI'll answer it in real-time:</div>
    </div>
  );
};

function InspirationComponent() {
  return (
    <a className="ml-1 text-gray-500 hover:underline cursor-pointer hover:text-black" target="_blank" href="https://twitter.com/search?q=to%3Ashl%20(business%20OR%20product%20OR%20entrepreneur%20OR%20money%20OR%20market)%20%3F&src=typed_query&f=top">?</a>
  );
}

function TestimonialsComponent() {
  const [loaded, setLoaded] = useState(false);

  const handleLoad = () => {
      setLoaded(true);
  };

  const tweets = [
    '1667578167618568196',
    '1668979672699351042',
    '1668440758934970380',
    '1666808687888044035',
    '1668966762161790977',
    '1666859137362276365'
  ];

  return (
    <div className="mt-8">
      <div className="text-2xl font-bold text-center">What Readers Are Saying</div>
      <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 md:grid-cols-3">
        {tweets.map((tweet, index) => (
          <div key={index} className="p-4">
            {!loaded && <p>Loading Testimonial...</p>}
            <TwitterTweetEmbed tweetId={tweet} onLoad={handleLoad} />
          </div>
        ))}
      </div>
    </div>
  );
};

function App() {
  return (
    <div className="flex flex-col justify-center items-center">
      <header>
        <HeroImageComponent />
        <TextComponent />
      </header>
      <div>
        <TextBox />
        <TestimonialsComponent />
      </div>
      <footer className="flex flex-row justify-center items-center text-lg text-gray-500">
        Project by 
        <a className="m-1 hover:underline" target="_blank" href="https://www.twitter.com/catsarecuter98">Hide Shidara</a> • 
        <a className="m-1 hover:underline" target="_blank" href="https://github.com/catsarebetter98/35862faac2fe3a92c2d8259109246595a9bebe65">Fork on GitHub</a>
      </footer>
    </div>
  );
}

export default App;
