
/// Module: pixelpawn
module pixelpawn::pixelpawn{

    use sui::object::{UID, new}; 
    use sui::clock::Clock;
    use sui::kiosk::{Kiosk, KioskOwnerCap};
    use sui::tx_context::TxContext;


    // Struct for ChronoKiosk that will include time-locked items
    public struct PixelPawn has key, store {
        id: UID,
        kiosk: Kiosk,

    }

    // Function to create a time-locked kiosk
    public fun create_pixel_pawn(ctx: &mut TxContext): (PixelPawn, KioskOwnerCap) {
        let (kiosk, owner_cap) = sui::kiosk::new(ctx);
        let id = new(ctx);
        (PixelPawn { id, kiosk }, owner_cap)
    }



    

}

module pixelpawn::offer_ptb {
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::transfer_policy::{Self, TransferPolicy};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    //use 0x2::devnet_nft::{Self, DevNetNFT};

   

    // Your OfferPTB struct remains the same
    public struct OfferPTB has key {
        id: UID,
        // Update nft_id to match your WrappedNFT type
        nft: ,
        pawner: address,
        lender: Option<address>,
        loan_amount: u64,
        interest_rate: u64,
        duration: u64,
        timestamp: u64,
        loan_status: u8, // 0: Open, 1: Loaned, 2: Finished
        repayment_status: u8, // 0: Pending, 1: Repaid, 2: Defaulted
    }

    // Create the TransferPolicy for WrappedNFT
    public entry fun init(ctx: &mut TxContext) {
        let publisher = tx_context::sender(ctx);
        let (transfer_policy, _) = transfer_policy::new<WrappedNFT>(&publisher, ctx);
        transfer::share_object(transfer_policy);
    }

    public entry fun create_offer(
        nft: OriginalNFTType,
        loan_amount: u64,
        interest_rate: u64,
        duration: u64,
        ctx: &mut TxContext,
    ) {
        let pawner = tx_context::sender(ctx);
        // Wrap the original NFT
        let wrapped_nft = WrappedNFT {
            id: object::new(ctx),
            inner_nft: nft,
        };
        // Obtain the TransferPolicy<WrappedNFT>
        let transfer_policy = /* Obtain the shared TransferPolicy<WrappedNFT> */;
        // Lock the WrappedNFT in the kiosk
        kiosk::lock(&mut self.kiosk, &self.kiosk_owner_cap, &transfer_policy, wrapped_nft);

        let offer = OfferPTB {
            offer_id: generate_offer_id(),
            nft_id,
            pawner,
            lender: None,
            loan_amount,
            interest_rate,
            duration,
            timestamp: tx_context::timestamp(ctx),
            loan_status: 0,
            repayment_status: 0,
        };
        // Store offer in the pawn shop contract
        self.offers.insert(offer.offer_id, offer);
    }

    public entry fun accept_offer(
        offer_id: u64,
        ctx: &mut TxContext,
    ) {
        let lender = tx_context::sender(ctx);
        let offer = self.offers.get_mut(&offer_id).expect("Offer not found");
        assert!(offer.loan_status == 0, "Offer already accepted");
        // Transfer funds from lender to pawner
        transfer_sui_from_sender(offer.loan_amount, ctx);
        transfer_sui(self_address, offer.pawner, offer.loan_amount);
        // Update offer
        offer.lender = Some(lender);
        offer.loan_status = 1;
        offer.timestamp = tx_context::timestamp(ctx); // Update timestamp to loan start time
    }

    public entry fun repay_loan(
        offer_id: u64,
        ctx: &mut TxContext,
    ) {
        let pawner = tx_context::sender(ctx);
        let offer = self.offers.get_mut(&offer_id).expect("Offer not found");
        assert!(offer.loan_status == 1, "Loan not active");
        assert!(pawner == offer.pawner, "Only pawner can repay");
        let current_time = tx_context::timestamp(ctx);
        assert!(current_time <= offer.timestamp + offer.duration, "Loan duration expired");
        // Calculate repayment amount
        let interest = calculate_interest(offer.loan_amount, offer.interest_rate);
        let total_due = offer.loan_amount + interest;
        let platform_fee = calculate_platform_fee(interest);
        let lender_amount = total_due - platform_fee;
        // Transfer repayment from pawner to lender and platform fee to shop owner
        transfer_sui_from_sender(total_due, ctx);
        transfer_sui(self_address, offer.lender.unwrap(), lender_amount);
        transfer_sui(self_address, self.shop_owner, platform_fee);
        // Unlock NFT and return to pawner
        kiosk::take(&mut self.kiosk, &self.kiosk_owner_cap, offer.nft_id);
        transfer_nft(self_address, pawner, offer.nft_id);
        // Update offer
        offer.loan_status = 2; // Finished
        offer.repayment_status = 1; // Repaid
    }

    public entry fun claim_nft(
        offer_id: u64,
        ctx: &mut TxContext,
    ) {
        let lender = tx_context::sender(ctx);
        let offer = self.offers.get_mut(&offer_id).expect("Offer not found");
        assert!(offer.loan_status == 1, "Loan not active");
        assert!(Some(lender) == offer.lender, "Only lender can claim NFT");
        let current_time = tx_context::timestamp(ctx);
        assert!(current_time > offer.timestamp + offer.duration, "Loan duration not expired");
        // Transfer NFT to lender
        kiosk::take(&mut self.kiosk, &self.kiosk_owner_cap, offer.nft_id);
        transfer_nft(self_address, lender, offer.nft_id);
        // Update offer
        offer.loan_status = 2; // Finished
        offer.repayment_status = 2; // Defaulted
    }
}


