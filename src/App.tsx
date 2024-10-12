// src/App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import MyNFTs from './pages/myNFTs';
import MyOffers from './pages/MyOffers';
import Marketplace from './pages/Marketplace';
import Navbar from './components/Navbar';

function App() {
  return (
    <BrowserRouter>
      <Navbar />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/my-nfts" element={<MyNFTs />} />
        <Route path="/my-offers" element={<MyOffers />} />
        <Route path="/marketplace" element={<Marketplace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;