// src/pages/MyNFTs.tsx
import React, { useEffect, useState } from 'react';
import { useCurrentAccount, useSuiClient } from '@mysten/dapp-kit';
import NFTCard from '../components/NFTCard';
import type { SuiObjectResponse } from '@mysten/sui/client';

const MyNFTs = () => {
  const currentAccount = useCurrentAccount();
  const suiClient = useSuiClient();
  const [nfts, setNfts] = useState<SuiObjectResponse[]>([]);

  useEffect(() => {
    const fetchNFTs = async () => {
      if (currentAccount?.address) {
        console.log("2")
        try {
          const response = await suiClient.getOwnedObjects({
            owner: currentAccount.address, 
            options: {
              showContent: true,
              showType: true,
              showDisplay: true,
            },
          });
          console.log("3", response)
          setNfts(response.data);
        } catch (error) {
          console.error('Error fetching NFTs:', error);
        }
      }
    };

    fetchNFTs();
  }, [currentAccount, suiClient]);

  if (!currentAccount) {
    return <div className="p-4">Please connect your wallet to view your NFTs.</div>;
  }

  // Filter out NFTs where data is undefined or null
  const validNfts = nfts.filter((nft) => nft.data != null);

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">My NFTs</h1>
      {validNfts.length === 0 ? (
        <p>You don't have any NFTs.</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {validNfts.map((nft) => (
            <NFTCard key={nft.data!.objectId} nft={nft} />
          ))}
        </div>
      )}
    </div>
  );
};

export default MyNFTs;