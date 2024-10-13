import React from 'react';
import { Transaction } from '@mysten/sui/transactions';
import { PACKAGE_ID, TESTNET_PIXEL_PAWN_OBJECT_ID } from '../constants';
import { useSignAndExecuteTransaction, useSuiClient } from '@mysten/dapp-kit';

const OfferCard = ({ offer }) => {
  const client = useSuiClient();
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();

  const withdrawOffer = async (nft_id) => {
    const nft = await client.getObject({
      id: nft_id,
      options: {
        showType: true,
      },
    });
    const tx = new Transaction();
    tx.moveCall({
      target: `${PACKAGE_ID}::pixelpawn::withdraw_offer`,
      arguments: [
        tx.object(TESTNET_PIXEL_PAWN_OBJECT_ID),
        tx.object(nft_id),
      ],
    });
    tx.setGasBudget(10000000);

    signAndExecute(
      {
        transaction: tx,
      },
      {
        onSuccess: (result) => {
          console.log('Offer canceled successfully:', result);
        },
        onError: (error) => {
          console.error('Error canceling offer:', error);
        },
      }
    );
  };

  const payBackLoan = async (nft_id, total_due) => {
    const tx = new Transaction();
    const nft = await client.getObject({
      id: nft_id,
      options: {
        showType: true,
      },
    });
    const coin = tx.splitCoins(tx.gas, [tx.pure.u64(total_due)]);
    tx.moveCall({
      target: `${PACKAGE_ID}::pixelpawn::repay_loan`,
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
          console.log('Offer canceled successfully:', result);
        },
        onError: (error) => {
          console.error('Error canceling offer:', error);
        },
      }
    );
  };
  // Destructure offer fields
  const { objectId, loan_amount, duration, interest_rate, nft_id, loan_status } = offer;
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
          {loan_status === 1 && (
            <button className="btn btn-primary" onClick={() => payBackLoan(nft_id, amount_due(loan_amount, interest_rate))}>
              Pay Back
            </button>
          )}
          <button className="btn btn-secondary" onClick={() => withdrawOffer(nft_id)}>
            Cancel Offer
          </button>
        </div>
      </div>
    </div>
  );
};

const amount_due = (loan_amount : number, interest_rate : number) => {loan_amount * (10000 + interest_rate) / 10000};

export default OfferCard;