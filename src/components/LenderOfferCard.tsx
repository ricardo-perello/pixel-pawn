import React, { useEffect, useState } from 'react';
import { Transaction } from '@mysten/sui/transactions';
import { PACKAGE_ID, TESTNET_PIXEL_PAWN_OBJECT_ID } from '../constants';
import { useCurrentAccount, useSignAndExecuteTransaction, useSuiClient } from '@mysten/dapp-kit';

const LenderOfferCard = ({ offer }) => {
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();
  const client = useSuiClient();
  
  const claimNFT = async (nft_id) => {
    const nft = await client.getObject({
      id: nft_id,
      options: {
        showType: true,
      },
    });
    const tx = new Transaction();
    tx.moveCall({
      target: `${PACKAGE_ID}::pixelpawn::claim_nft`,
      arguments: [
        tx.object(TESTNET_PIXEL_PAWN_OBJECT_ID),
        tx.object(nft_id),
        tx.object('0x6')
      ],
      typeArguments: [nft.data?.type!],
    });
    tx.setGasBudget(10000000);

    signAndExecute(
      {
        transaction: tx,
      },
      {
        onSuccess: (result) => {
          console.log('NFT Claimed Successfully', result);
        },
        onError: (error) => {
          console.error('Error claiming NFT:', error);
        },
      }
    );
  };
  const current_timestamp = new Date().getTime(); // Get the current timestamp

  const { objectId, loan_amount, duration, interest_rate, nft_id, loan_status, timestamp } = offer;

  return (
    <div className="card bg-base-200 shadow-xl min-w-full min-h-[300px] p-8 m-6">
      <div className="card-body">
        <h2 className="card-title text-xl mb-4">Offer ID: {objectId}</h2>
        {/* Display the relevant offer details */}
        <p className="text-lg mb-2">Loan Amount: {loan_amount}</p>
        <p className="text-lg mb-2">Duration: {duration}</p>
        <p className="text-lg mb-2">Interest Rate: {interest_rate / 10000}</p>
        <p className="text-lg mb-2">NFT ID: {nft_id}</p>
        <p className="text-lg mb-4">
          Loan Status: {loan_status === 0 ? 'On Marketplace' : 'Accepted'}
        </p>
        <div className="card-actions justify-end space-x-4">
          {/* Conditionally render the "Pay Back" button if loan_status is 2 */}
          {timestamp + duration > current_timestamp}  
            <button className="btn btn-primary" onClick={() => claimNFT(nft_id)}>
              Claim NFT
            </button>
          
        </div>
      </div>
    </div>
  );
};

export default LenderOfferCard;