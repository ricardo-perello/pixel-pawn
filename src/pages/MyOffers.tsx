import { useSuiClientQuery, useCurrentAccount } from '@mysten/dapp-kit';
import Navbar from '../components/Navbar'; // Import your Navbar component

const PACKAGE_ID = 0x0;

// Custom hook to fetch offers
const useFetchOffers = () => {
  const account = useCurrentAccount();

  if (!account) {
    return { data: [], isLoading: false, isError: false }; // Return empty data if no account is connected
  }

  // Query to fetch OfferPTB structs where the pawner is the connected account
  const { data, isLoading, isError, error, refetch } = useSuiClientQuery(
    'getOwnedObjects', // This should match your Move function name
    {
      owner: account.address,
      // The filter condition is specific to your implementation
      filter: {
        MatchAll: [
          {
            StructType: `${PACKAGE_ID}::pixelpawn::Offer`, // Specify the struct type
          },
        ],
      },
      options: {
        showContent: true,
        showDisplay: true,
        showType: true,
      },
    },
    { queryKey: ['OffersPTB'] }, // Optional query key for caching
  );

  return {
    data: data && data.data.length > 0 ? data.data : [], // Return the fetched data
    isLoading,
    isError,
    error,
    refetch,
  };
};

const MyOffers = () => {
  const { data: offers, isLoading, isError, error, refetch } = useFetchOffers();
  

  return (
    <div className="min-h-screen bg-base-200">
      <Navbar />
      <div className="h-24"></div> {20}{20}
      <main className="container mx-auto px-4 py-8 mt-8"> {100}{100}
        <section className="hero bg-base-100 rounded-lg shadow-md mb-8">{20}
          <h2>Here are all the NFTs you have put up on offer</h2>
        </section>
        <section>
          {isLoading && <p>Loading offers...</p>}
          {isError && <p>Error fetching offers: {error.message}</p>}
          {offers.length > 0 ? (
            offers.map((offer) => (
              <div key={offer.nft_id} className="offer-card p-4 border rounded mb-4">{20}
                <h3>NFT ID: {offer.content.fields.id}</h3>
                <p>Pawner: {offer.pawner}</p>
                <p>Lender: {offer.lender}</p>
                <p>Loan Amount: {offer.loan_amount}</p>
                <p>Interest Rate: {offer.interest_rate}%</p>
                <p>Duration: {offer.duration} ms</p>
                <p>Loan Status: {offer.loan_status}</p>
                <p>Repayment Status: {offer.repayment_status}</p>
              </div>
            ))
          ) : (
            <p>No offers found.</p>
          )}
          <button onClick={refetch} className="btn btn-secondary mt-8"> Refresh Offers</button>
        </section>
      </main>
    </div>
  );
};

export default MyOffers;
