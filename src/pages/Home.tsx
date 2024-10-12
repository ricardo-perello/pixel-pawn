// src/pages/Home.tsx
import React from 'react';

const Home = () => {
  return (
    <div className="flex flex-col items-center justify-center h-screen bg-base-200">
      <h1 className="text-5xl font-bold mb-4">Welcome to PixelPawn</h1>
      <p className="text-lg mb-8">Pawn your NFTs securely on the Sui blockchain.</p>
      <a href="/my-nfts" className="btn btn-primary">
        Get Started
      </a>
    </div>
  );
};

export default Home;