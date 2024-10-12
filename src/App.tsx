import { ConnectButton, useCurrentAccount } from "@mysten/dapp-kit";
import { isValidSuiObjectId } from "@mysten/sui/utils";
import { Box, Container, Flex, Heading } from "@radix-ui/themes";
import { useState } from "react";
import { PixelPawn } from "./PixelPawn";
import { CreateCounter } from "./AddNFT";
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Main from './pages/Main';
import MyNFTs from './pages/myNFTs';
import MyOffers from './pages/MyOffers';

function App() {
  const currentAccount = useCurrentAccount();
  const [counterId, setCounter] = useState(() => {
    const hash = window.location.hash.slice(1);
    return isValidSuiObjectId(hash) ? hash : null;
  });

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Main />} />
        <Route path="/myNFTs" element={<MyNFTs />} />
        <Route path="/myOffers" element={<MyOffers />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
