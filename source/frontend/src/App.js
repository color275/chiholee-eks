import React from 'react';
import './App.css'; // You can create this file for styling

const productImages = [
  'image1.jpg',
  'image2.jpg',
  'image3.jpg',
  // Add more image URLs as needed
];

const App = () => {
  return (
    <div className="app">
      <header>
        <nav>
          <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/products">Products</a></li>
            <li><a href="/about">About Us</a></li>
            {/* Add more menu items as needed */}
          </ul>
        </nav>
      </header>
      <h1>Product Gallery</h1>
      <div className="grid-container">
        {productImages.map((image, index) => (
          <div key={index} className="grid-item">
            <img src={image} alt={`Product ${index + 1}`} />
          </div>
        ))}
      </div>
    </div>
  );
};

export default App;