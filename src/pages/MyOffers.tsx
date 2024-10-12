import { useResolveSuiNSName } from '@mysten/dapp-kit';
import { useSuiClientQuery } from '@mysten/dapp-kit';
import { ConnectModal, useCurrentAccount } from '@mysten/dapp-kit';
import Navbar from '../components/Navbar'; // Import your Navbar component
import { Box, Container, Flex, Heading } from "@radix-ui/themes";
import NFTLogic from '../components/NFTLogic';

// Call a list NFTs function from pixelPawn
const myOffers = () => {
  return (
    <div className="min-h-screen bg-base-200">
      <Navbar />
      <main className="container mx-auto px-4 py-8 mt-16">
        <section className="hero bg-base-100 rounded-lg shadow-md mb-8">
          <body>Here are all the NFTs you have put up on offer</body>
        </section>
      </main>
    </div>
  );
}
  
export default myOffers;
