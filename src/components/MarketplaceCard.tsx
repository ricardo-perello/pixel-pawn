import { useSuiClient } from '@mysten/dapp-kit';
import { Transaction } from '@mysten/sui/transactions';
import React from 'react';
import { PACKAGE_ID, TESTNET_PIXEL_PAWN_OBJECT_ID } from '../constants';
import { useCurrentAccount, useSignAndExecuteTransaction } from '@mysten/dapp-kit';

const MarketplaceOfferCard = ({ market }, { address }) => {
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();
  const client = useSuiClient();

  const acceptOffer = async (nft_id, loan_amount) => {
    const tx = new Transaction(); 
    const nft = await client.getObject({
        id: nft_id,
        options: {
          showType: true,
        },
      });
      const coin = tx.splitCoins(tx.gas, [tx.pure.u64(loan_amount)]);
      tx.moveCall({
        target: `${PACKAGE_ID}::pixelpawn::accept_offer`,
        arguments: [
          tx.object(TESTNET_PIXEL_PAWN_OBJECT_ID),
          tx.object(nft_id),
          tx.object('0x6'),
          coin
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
            console.log('Offer accepted successfully:', result);
          },
          onError: (error) => {
            console.error('Error accepting offer:', error);
          },
        }
      );
  }
  if (!market) {
    return <p>No offer data available</p>; // Add a fallback if market is undefined
  }

  const { objectId, loan_amount, duration, interest_rate, nft_id, loan_status, pawner } = market;
  return (
    <div className="card bg-base-200 shadow-xl min-w-full min-h-[300px] p-8 m-6">
      <div className="card-body">
        <h2 className="card-title text-xl mb-4">Offer ID: {objectId}</h2>
        <p className="text-lg mb-2">Loan Amount: {loan_amount}</p>
        <p className="text-lg mb-2">Duration: {duration}</p>
        <p className="text-lg mb-2">Interest Rate: {interest_rate / 10000}</p>
        <p className="text-lg mb-2">NFT ID: {nft_id}</p>
        <p className="text-lg mb-4">
          Loan Status: {loan_status === 0 ? 'On Marketplace' : 'Accepted'}
        </p>
        <div className="card-actions justify-end space-x-4">
        <button className="btn btn-secondary" onClick={() => acceptOffer(nft_id, loan_amount)}>Accept Offer</button>
        </div>
      </div>
    </div>
  );
};

export default MarketplaceOfferCard;