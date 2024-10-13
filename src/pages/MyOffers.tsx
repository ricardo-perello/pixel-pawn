import { useSuiClientQuery, useCurrentAccount, useSuiClient } from '@mysten/dapp-kit';
import Navbar from '../components/Navbar'; // Import your Navbar component
import { PACKAGE_ID, PIXEL_PAWN_OFFERS } from '../constants';
import  OfferCard from '../components/OfferCard';
import LenderOfferCard from "../components/LenderOfferCard";
import { SuiObjectResponse } from '@mysten/sui/client';
import React, { useEffect, useState } from 'react';

const MyOfferList = ({ offers }) => {
    console.log("offers:" ,offers);
  return (
    <div className="offer-list">
      {offers.length > 0 ? (
        offers.map((offer, index) => (
          <OfferCard key={index} offer={offer} />
        ))
      ) : (
        <p>No NFTs currently offered up.</p>
      )}
    </div>
  );
};

const LenderOfferList = ({ offers }) => {
    console.log("Lender offers:" ,offers);
  return (
    <div className="offer-list">
      {offers.length > 0 ? (
        offers.map((offer, index) => (
          <LenderOfferCard key={index} offer={offer} />
        ))
      ) : (
        <p>Not currently lending money.</p>
      )}
    </div>
  );
};


const MyOffers = () => {
    const client = useSuiClient();
    const [myOffers, setOffers] = useState([]);
    const [lenderOffers, setLenderOffers] = useState([]);
    const account = useCurrentAccount();
    const address = account?.address;
  useEffect(() => {
    const fetchOffers = async () => {
      const reponse = await client.getDynamicFields({
        parentId: PIXEL_PAWN_OFFERS
      });
      const myOffers = [];
      const lenderOffers = [];
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
        
          console.log("offerData : ",offerData);
          (address == offerData.pawner) ? myOffers.push(offerData) : null;
          (address == offerData.lender) ? lenderOffers.push(offerData) : null;
        }
      }
      setOffers(myOffers);
      setLenderOffers(lenderOffers);
    };

    fetchOffers();
  }, []);

  return (
    <div>
      <h1>Marketplace Offers</h1>
      <MyOfferList offers={myOffers} />

      <h1>Lender Offers</h1>
      <LenderOfferList offers={lenderOffers} /> {/* Render lender offers in the same way */}
    </div>
  );
};

export default MyOffers;
