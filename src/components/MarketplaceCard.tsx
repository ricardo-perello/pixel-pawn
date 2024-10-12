// src/components/MarketplaceOfferCard.tsx
import React from 'react';
import { Transaction } from '@mysten/sui/transactions';
import { useSignAndExecuteTransaction, useSuiClient } from '@mysten/dapp-kit';

const MarketplaceOfferCard = ({ offer }) => {
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();
  const suiClient = useSuiClient();

  const fundOffer = () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${process.env.REACT_APP_PACKAGE_ID}::pixel_pawn::fund_offer`,
      arguments: [tx.object(offer.data.objectId)],
      // You may need to include payment for the loan amount
    });

    signAndExecute(
      {
        transaction: tx,
      },
      {
        onSuccess: (result) => {
          console.log('Offer funded successfully:', result);
        },
        onError: (error) => {
          console.error('Error funding offer:', error);
        },
      },
    );
  };

  return (
    <div className="card bg-base-100 shadow-xl">
      <div className="card-body">
        <h2 className="card-title">Offer ID: {offer.data.objectId}</h2>
        {/* Display offer details like loan amount, duration, etc. */}
        <p>Loan Amount: {offer.data.content.fields.loan_amount}</p>
        <p>Duration: {offer.data.content.fields.duration}</p>
        <div className="card-actions justify-end">
          <button className="btn btn-primary" onClick={fundOffer}>
            Fund Offer
          </button>
        </div>
      </div>
    </div>
  );
};

export default MarketplaceOfferCard;