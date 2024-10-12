// src/pages/Marketplace.tsx
import React, { useEffect, useState } from 'react';
import { useCurrentAccount, useSuiClient } from '@mysten/dapp-kit';
import MarketplaceOfferCard from '../components/MarketplaceCard';

const Marketplace = () => {
  const currentAccount = useCurrentAccount();
  const suiClient = useSuiClient();
  const [offers, setOffers] = useState([]);

  useEffect(() => {
    const fetchMarketplaceOffers = async () => {
      try {
        // Fetch all offers
        const response = await suiClient.queryEvents({
          query: {
            MoveEventType: `${process.env.REACT_APP_PACKAGE_ID}::pixel_pawn::OfferCreated`,
          },
        });
        // Process events to get offer IDs
        const offerIds = response.data.map((event) => event.parsedJson.offer_id);

        // Fetch offer objects
        const offersData = await suiClient.multiGetObjects({
          ids: offerIds,
          options: {
            showContent: true,
          },
        });

        // Optionally filter out user's own offers
        const filteredOffers = offersData.filter(
          (offer) => offer.data.owner !== currentAccount?.address,
        );

        setOffers(filteredOffers);
      } catch (error) {
        console.error('Error fetching marketplace offers:', error);
      }
    };

    fetchMarketplaceOffers();
  }, [currentAccount, suiClient]);

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">Marketplace</h1>
      {offers.length === 0 ? (
        <p>No offers available at the moment.</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {offers.map((offer) => (
            <MarketplaceOfferCard key={offer.data.objectId} offer={offer} />
          ))}
        </div>
      )}
    </div>
  );
};

export default Marketplace;