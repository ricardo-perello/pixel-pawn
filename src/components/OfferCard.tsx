// src/components/OfferCard.tsx
import React from 'react';

const OfferCard = ({ offer }) => {
  // Extract offer details from offer object
  const { objectId, content } = offer.data;

  return (
    <div className="card bg-base-100 shadow-xl">
      <div className="card-body">
        <h2 className="card-title">Offer ID: {objectId}</h2>
        {/* Display offer details like loan amount, duration, etc. */}
        <p>Loan Amount: {content.fields.loan_amount}</p>
        <p>Duration: {content.fields.duration}</p>
        <div className="card-actions justify-end">
          {/* You can add functionality to cancel the offer */}
          <button className="btn btn-secondary">Cancel Offer</button>
        </div>
      </div>
    </div>
  );
};

export default OfferCard;