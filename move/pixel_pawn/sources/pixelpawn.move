
/// Module: pixelpawn
module pixelpawn::pixelpawn{

    use sui::object::{UID, new}; 
    use sui::clock::Clock;
    use sui::dynamic_object_field as dof;
    use sui::table::{Self, Table};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::balance;
    use sui::pay;

    const PLATFORM_RATE: u64 = 2;
    // Struct for ChronoKiosk that will include time-locked items
    public struct PixelPawn has key, store {
        id: UID,
        owner: address,
        offers: Table<ID, Offer>, // Table to link NFTs to offers
    }

    // Function to create a time-locked kiosk
    public fun create_pixel_pawn(ctx: &mut TxContext): (PixelPawn) {
        let id = new(ctx);
        let owner = tx_context::sender(ctx);
        let offers = table::new<ID, Offer>(ctx);
        (PixelPawn {id, owner, offers})
    }

    fun add_nft<T: key+store>(nft: T, pix: &mut PixelPawn, ctx: &mut TxContext) {
        let id = object::id(&nft);
        dof::add(&mut pix.id, id, nft);
    }

    fun remove_nft<T: key+store>(nft_id: ID, pix: &mut PixelPawn, ctx: &mut TxContext): T {
        dof::remove(&mut pix.id, nft_id)
    }




    // Your OfferPTB struct remains the same
    public struct Offer has store {
        nft_id: ID,
        pawner: address,
        lender: address,
        loan_amount: u64,
        interest_rate: u64,
        duration: u64,
        timestamp: u64,
        loan_status: u8, // 0: Open, 1: Loaned
    }


    public entry fun create_offer<T: key+store>(
        pix: &mut PixelPawn,
        nft: T,
        loan_amount: u64,
        interest_rate: u64,
        duration: u64,
        ctx: &mut TxContext,
    ) {
        let pawner = tx_context::sender(ctx);
        let nft_id = object::id(&nft);
        add_nft(nft, pix, ctx);
        let offer = Offer {
            nft_id,
            pawner,
            lender: @0x0,
            loan_amount,
            interest_rate,
            duration,
            timestamp: 0, // 0 at first since we start counting when offer is accepted
            loan_status: 0,
        };
        // Store offer in the pawn shop contract
        pix.offers.add(nft_id, offer);
    }

    public entry fun withdraw_offer<T: key+store>(
        pix: &mut PixelPawn,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let pawner = tx_context::sender(ctx);
        let offer = pix.offers.remove(nft_id);
        assert!(offer.loan_status == 0);
        assert!(offer.pawner == pawner);
         
        let Offer {
            nft_id:_,
            pawner:_,
            lender:_,
            loan_amount:_,
            interest_rate:_,
            duration:_,
            timestamp:_,
            loan_status:_, // 0: Open, 1: Loaned, 2: Finished
        } = offer;


        let nft: T = remove_nft(nft_id, pix, ctx);
        transfer::public_transfer(nft, pawner);
    }

    public entry fun accept_offer(
        pix: &mut PixelPawn,
        nft_id: ID,
        clock: &Clock,
        coins: &mut Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let lender = tx_context::sender(ctx);
        let offer = pix.offers.borrow_mut(nft_id);
        assert!(offer.loan_status == 0);
         
        // Update offer
        offer.lender = lender;
        offer.loan_status = 1;
        offer.timestamp = clock.timestamp_ms(); // Update timestamp to loan start time

        // Transfer funds from lender to pawner
        pay::split_and_transfer(coins, offer.loan_amount, offer.pawner, ctx);
    }

    public entry fun repay_loan <T: key+store>(
        pix: &mut PixelPawn,
        nft_id: ID,
        clock: &Clock,
        coins: &mut Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let pawner = tx_context::sender(ctx);
        let offer = pix.offers.remove(nft_id);
        assert!(offer.loan_status == 1);
        assert!(pawner == offer.pawner);
        let current_time = clock.timestamp_ms();
        assert!(current_time <= offer.timestamp + offer.duration);

        // Calculate repayment amount
        let total_due = (offer.loan_amount * (100 + offer.interest_rate))/100;
        let platform_fee = (total_due * PLATFORM_RATE)/100;
        let lender_amount = total_due - platform_fee;
        
        // delete offer;
        let Offer {
            nft_id:_,
            pawner:_,
            lender:_,
            loan_amount:_,
            interest_rate:_,
            duration:_,
            timestamp:_,
            loan_status:_, // 0: Open, 1: Loaned, 2: Finished
        } = offer;
        // Unlock NFT and return to pawner
        let nft: T = remove_nft(nft_id, pix, ctx);
        transfer::public_transfer(nft, pawner);

        // Transfer repayment from pawner to lender and platform fee to shop owner
        pay::split_and_transfer(coins, lender_amount, offer.lender, ctx);
        pay::split_and_transfer(coins, platform_fee, pix.owner, ctx);
    }

    public entry fun claim_nft<T: key+store>(
        pix: &mut PixelPawn,
        nft_id: ID,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        let lender = tx_context::sender(ctx);
        let offer = pix.offers.remove(nft_id);
        assert!(offer.loan_status == 1);
        assert!(lender == offer.lender);
       let current_time = clock.timestamp_ms();
        assert!(current_time > offer.timestamp + offer.duration);
        
        let Offer {
            nft_id,
            pawner:_,
            lender:_,
            loan_amount:_,
            interest_rate:_,
            duration:_,
            timestamp:_,
            loan_status:_, // 0: Open, 1: Loaned, 2: Finished
        } = offer;
        // Transfer NFT to lender
        let nft: T = remove_nft(nft_id, pix, ctx);
        transfer::public_transfer(nft, lender);
    }
}