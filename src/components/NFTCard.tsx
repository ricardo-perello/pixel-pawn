import React, { useState, useEffect, useRef } from 'react';
import { Transaction } from '@mysten/sui/transactions';
import { useSignAndExecuteTransaction } from '@mysten/dapp-kit';
import { PACKAGE_ID } from '../constants';

interface NFTCardProps {
  nft: any;
}

const NFTCard: React.FC<NFTCardProps> = ({ nft }) => {
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [loanAmount, setLoanAmount] = useState<number>(0);
  const [duration, setDuration] = useState<number>(0);
  const image = nft.data.content.fields.image_id
    ? nft.data.content.fields.image_id
    : nft.data.content.fields.image_url;

  // Reference to the modal for focus management
  const modalRef = useRef<HTMLDivElement>(null);

  // Function to handle toggling the modal
  const toggleModal = () => {
    setIsModalOpen(!isModalOpen);
  };

  // Function to handle the pawn NFT action
  const pawnNFT = () => {
    const tx = new Transaction();
    tx.moveCall({
      target: `${PACKAGE_ID}::pixel_pawn::create_offer`,
      arguments: [
        tx.object(nft.data.objectId),
        tx.pure(loanAmount),
        tx.pure(duration),
      ],
    });
    signAndExecute(
      {
        transaction: tx,
      },
      {
        onSuccess: (result) => {
          console.log('Offer created successfully:', result);
          toggleModal(); // Close the modal on success
        },
        onError: (error) => {
          console.error('Error creating offer:', error);
        },
      }
    );
  };

  // Close modal on "Escape" key press
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isModalOpen) {
        toggleModal();
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => {
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [isModalOpen]);

  // Close modal when clicking outside the modal content
  const handleClickOutside = (e: MouseEvent) => {
    if (
      modalRef.current &&
      !modalRef.current.contains(e.target as Node) &&
      isModalOpen
    ) {
      toggleModal();
    }
  };

  useEffect(() => {
    if (isModalOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    } else {
      document.removeEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isModalOpen]);

  // Focus on the modal when it opens
  useEffect(() => {
    if (isModalOpen && modalRef.current) {
      modalRef.current.focus();
    }
  }, [isModalOpen]);

  return (
    <div className="card bg-base-100 shadow-xl">
      <figure>
        {/* Display NFT image if available */}
        {image && (
          <img src={image} alt="NFT" className="w-full h-48 object-cover" />
        )}
      </figure>
      <div className="card-body">
        <h2 className="card-title">NFT ID: {nft.data.objectId}</h2>
        <p>{nft.data.content.fields.name}</p>
        <div className="card-actions justify-end">
          <button className="btn btn-primary" onClick={toggleModal}>
            Pawn NFT
          </button>
        </div>
      </div>

      {/* Modal for inputting loanAmount and duration */}
      {isModalOpen && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black"
          role="dialog"
          aria-modal="true"
          aria-labelledby="modal-title"
        >
          <div
            ref={modalRef}
            tabIndex={-1}
            className="bg-white rounded-lg shadow-xl p-8 w-full max-w-lg relative"
          >
            <h3 id="modal-title" className="font-bold text-2xl mb-4">
              Pawn NFT
            </h3>
            <p className="mb-6">Enter the loan amount and duration</p>

            {/* Form Control for Loan Amount */}
            <div className="form-control mb-4">
              <label className="label">
                <span className="label-text">Loan Amount (SUI)</span>
              </label>
              <input
                type="number"
                value={loanAmount}
                onChange={(e) => setLoanAmount(Number(e.target.value))}
                className="input input-bordered w-full"
                placeholder="Enter loan amount"
                min="0"
              />
            </div>

            {/* Form Control for Duration */}
            <div className="form-control mb-6">
              <label className="label">
                <span className="label-text">Duration (Days)</span>
              </label>
              <input
                type="number"
                value={duration}
                onChange={(e) => setDuration(Number(e.target.value))}
                className="input input-bordered w-full"
                placeholder="Enter duration in days"
                min="1"
              />
            </div>

            {/* Action buttons */}
            <div className="flex justify-end space-x-4">
              <button
                className="btn btn-secondary"
                onClick={toggleModal}
              >
                Cancel
              </button>
              <button
                className="btn btn-primary"
                onClick={pawnNFT}
              >
                Submit
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default NFTCard;