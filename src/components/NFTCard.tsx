// src/components/NFTCard.tsx
import React from 'react';
import { Transaction } from '@mysten/sui/transactions';
import { useSignAndExecuteTransaction, useSuiClient } from '@mysten/dapp-kit';

const NFTCard = ({ nft }) => {
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();
  const suiClient = useSuiClient();

  const pawnNFT = () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${process.env.REACT_APP_PACKAGE_ID}::pixel_pawn::create_offer`,
      arguments: [tx.object(nft.data.objectId), tx.pure(loanAmount), tx.pure(duration)],
    });

    signAndExecute(
      {
        transaction: tx,
      },
      {
        onSuccess: (result) => {
          console.log('Offer created successfully:', result);
        },
        onError: (error) => {
          console.error('Error creating offer:', error);
        },
      },
    );
  };

  return (
    <div className="card bg-base-100 shadow-xl">
      <figure>
        {/* Display NFT image if available */}
        {nft.data.content.fields.url && (
          <img src={nft.data.content.fields.url} alt="NFT" />
        )}
      </figure>
      <div className="card-body">
        <h2 className="card-title">NFT ID: {nft.data.objectId}</h2>
        <p>{nft.data.content.fields.name}</p>
        <div className="card-actions justify-end">
          <button className="btn btn-primary" onClick={pawnNFT}>
            Pawn NFT
          </button>
        </div>
      </div>
    </div>
  );
};

export default NFTCard;