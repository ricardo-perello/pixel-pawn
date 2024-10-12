
/// Module: pixelpawn
module pixelpawn::pixelpawn{

    use sui::object::{UID, new}; 
    use sui::clock::Clock;
    use sui::dynamic_object_field as dof;
    use sui::table::{Self, Table};
    use sui::kiosk::{Kiosk, KioskOwnerCap};
    use sui::tx_context::{Self, TxContext};

    // Struct for ChronoKiosk that will include time-locked items
    public struct PixelPawn has key, store {
        id: UID,
        offers: Table<ID, OfferPTB>, // Table to link NFTs to offers
    }

    // Function to create a time-locked kiosk
    public fun create_pixel_pawn(ctx: &mut TxContext): (PixelPawn) {
        let id = new(ctx);
        let offers = table::new<ID, OfferPTB>(ctx);
        (PixelPawn {id, offers})
    }

    fun add_nft<T: key+store>(nft: T, pix: &mut PixelPawn, ctx: &mut TxContext) {
        let id = object::id(&nft);
        dof::add(&mut pix.id, id, nft);
    }

    fun remove_nft<T: key+store>(nft_id: ID, pix: &mut PixelPawn, ctx: &mut TxContext): T {
        dof::remove(&mut pix.id, nft_id)
    }




    // Your OfferPTB struct remains the same
    public struct OfferPTB has store {
        nft_id: ID,
        pawner: address,
        lender: address,
        loan_amount: u64,
        interest_rate: u64,
        duration: u64,
        timestamp: u64,
        loan_status: u8, // 0: Open, 1: Loaned, 2: Finished
        repayment_status: u8, // 0: Pending, 1: Repaid, 2: Defaulted
    }


    public entry fun create_offer<T: key+store>(
        pix: &mut PixelPawn,
        nft: T,
        loan_amount: u64,
        interest_rate: u64,
        duration: u64,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        let pawner = tx_context::sender(ctx);
        let nft_id = object::id(&nft);
        add_nft(nft, pix, ctx);
        let offer = OfferPTB {
            nft_id,
            pawner,
            lender: @0x0,
            loan_amount,
            interest_rate,
            duration,
            timestamp: 0, // 0 at first since we start counting when offer is accepted
            loan_status: 0,
            repayment_status: 0,
        };
        // Store offer in the pawn shop contract
        pix.offers.add(nft_id, offer);
    }

    public entry fun accept_offer(
        pix: &mut PixelPawn,
        nft_id: ID,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        let lender = tx_context::sender(ctx);
        let offer = pix.offers.borrow_mut(nft_id);
        assert!(offer.loan_status == 0);
        // Transfer funds from lender to pawner
        // TODO transfer the money
        // Update offer
        offer.lender = lender;
        offer.loan_status = 1;
        offer.timestamp = clock.timestamp_ms(); // Update timestamp to loan start time
    }

    public entry fun repay_loan(
        pix: &mut PixelPawn,
        nft_id: ID,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        let pawner = tx_context::sender(ctx);
        let offer = pix.offers.borrow_mut(nft_id);
        assert!(offer.loan_status == 1);
        assert!(pawner == offer.pawner);
        let current_time = clock.timestamp_ms();
        assert!(current_time <= offer.timestamp + offer.duration);
        // Calculate repayment amount
        let interest = calculate_interest(offer.loan_amount, offer.interest_rate);
        let total_due = offer.loan_amount + interest;
        let platform_fee = calculate_platform_fee(interest);
        let lender_amount = total_due - platform_fee;
        // Transfer repayment from pawner to lender and platform fee to shop owner
        //TODO transfer the money
        // Unlock NFT and return to pawner
        remove_nft(nft_id, pix, ctx);
        
        // Update offer
        offer.loan_status = 2; // Finished
        offer.repayment_status = 1; // Repaid
    }

    public entry fun claim_nft(
        pix: &mut PixelPawn,
        nft_id: ID,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        let lender = tx_context::sender(ctx);
        let offer = pix.offers.borrow_mut(nft_id);
        assert!(offer.loan_status == 1);
        assert!(lender == offer.lender);
       let current_time = clock.timestamp_ms();
        assert!(current_time > offer.timestamp + offer.duration);
        // Transfer NFT to lender
        //TODO transfer the NFT
        // Update offer
        offer.loan_status = 2; // Finished
        offer.repayment_status = 2; 
        }
}