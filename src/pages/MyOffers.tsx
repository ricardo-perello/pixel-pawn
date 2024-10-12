// src/pages/MyOffers.tsx
import React, { useEffect, useState } from 'react';
import { useCurrentAccount, useSuiClient } from '@mysten/dapp-kit';
import OfferCard from '../components/OfferCard';

const MyOffers = () => {
  const currentAccount = useCurrentAccount();
  const suiClient = useSuiClient();
  const [offers, setOffers] = useState([]);

  useEffect(() => {
    const fetchOffers = async () => {
      if (currentAccount?.address) {
        try {
          // Fetch offers where the user is the borrower
          const response = await suiClient.getOwnedObjects({
            owner: currentAccount.address,
            filter: {
              StructType: `${process.env.REACT_APP_PACKAGE_ID}::pixel_pawn::Offer`,
            },
            options: {
              showContent: true,
            },
          });
          setOffers(response.data);
        } catch (error) {
          console.error('Error fetching offers:', error);
        }
      }
    };

    fetchOffers();
  }, [currentAccount, suiClient]);

  if (!currentAccount) {
    return <div className="p-4">Please connect your wallet to view your offers.</div>;
  }

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">My Offered NFTs</h1>
      {offers.length === 0 ? (
        <p>You don't have any offered NFTs.</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {offers.map((offer) => (
            <OfferCard key={offer.data.objectId} offer={offer} />
          ))}
        </div>
      )}
    </div>
  );
};

export default MyOffers;