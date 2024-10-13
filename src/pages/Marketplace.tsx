// src/pages/Marketplace.tsx
import React, { useEffect, useState } from 'react';
import { useCurrentAccount, useSignAndExecuteTransaction, useSuiClient } from '@mysten/dapp-kit';
import MarketplaceOfferCard from '../components/MarketplaceCard';
import { PIXEL_PAWN_OFFERS } from '../constants';

const MarketList = ({ marketOffers, address }) => {
  console.log("offers:" ,marketOffers);
  return (
    <div className="offer-list">
      {marketOffers.length > 0 ? (
        marketOffers.map((marketOffer, index) => (
          <MarketplaceOfferCard key={index}  market={marketOffer} address = {address} />
        ))
      ) : (
        <p>No offers available.</p>
      )}
    </div>
  );
};

const Marketplace = () => {
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();
  const client = useSuiClient();
  const [marketOffers, setMarketOffers] = useState([]);
  const account = useCurrentAccount();
  const address = account?.address;

  useEffect(() => {
    const fetchMarketPlaceOffers = async () => {
      const reponse = await client.getDynamicFields({
        parentId: PIXEL_PAWN_OFFERS
      });
      const marketOffers = [];

      for (let item of reponse.data) {
        const resp = await client.getDynamicFieldObject({
          parentId: PIXEL_PAWN_OFFERS,
          name: item.name
        });
        console.log(resp);
        if (resp.data?.content?.dataType === 'moveObject') {
          const offerFields = resp.data.content.fields;
        console.log("offerFields : ",offerFields);
          const offerData = {
            objectId: resp.data.objectId,
            loan_amount : offerFields.value.fields.loan_amount ,
            duration: offerFields.value.fields.duration,
            interest_rate: offerFields.value.fields.interest_rate,
            nft_id: offerFields.value.fields.nft_id,
            pawner: offerFields.value.fields.pawner,
            loan_status: offerFields.value.fields.loan_status,
            lender: offerFields.value.fields.lender,
            timestamp: offerFields.value.fields.timestamp,
          };
        
          offerData.loan_status == 0 ? marketOffers.push(offerData) : null;
          console.log("offerData loan Status: ",offerData.loan_status);
        }
      }
      setMarketOffers(marketOffers);
    };

    fetchMarketPlaceOffers();
  }, []);

  return <MarketList marketOffers={marketOffers} address={address} />;
};

export default Marketplace;