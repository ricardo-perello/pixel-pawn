/*
const exact_amount = 12300;
const tx = new Transaction();
const coin = tx.splitCoins(tx.gas, [tx.pure.u64(exact_amount)]);
tx.moveCall({
target: `${packageId}::pixelpawn::repay_loan`,
arguments: [
    tx.object(${pixelPawnObjID}),
    tx.pure.id(${ntf_id}),
    tx.object("0x8"),
    coin
]
})
*/
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
    use sui::balance::{Self, Balance};
    use sui::pay;

    // Error codes
    const EIncorrectAmount: u64 = 0;
    const EIncorrenctPayment: u64 = 1;
    const EIncorrenctOwner: u64 = 2;

    const PLATFORM_RATE: u64 = 2;
    // Struct for ChronoKiosk that will include time-locked items
    public struct PixelPawn has key, store {
        id: UID,
        owner: address,
        offers: Table<ID, Offer>, // Table to link NFTs to offers
        fees: Balance<SUI>
    }

    //PixelPawn getters
    public fun get_owner(pix: PixelPawn): address{
        return pix.owner
    }

    public fun get_offers_size(pix: PixelPawn): u64{
        return pix.offers.length()
    }

    public fun get_offer(pix: PixelPawn, nft_id: ID): &Offer{
        return pix.offers.borrow(nft_id)
    }

    public fun get_fees(pix: PixelPawn): u64{
        return pix.fees.value()
    }

    public struct OwnerCap has key, store {
        id : UID,
        owner : address
    }

    // Function to create a time-locked kiosk
    public fun create_pixel_pawn(ctx: &mut TxContext): OwnerCap {
        let id = new(ctx);
        let owner = tx_context::sender(ctx);
        let offers = table::new<ID, Offer>(ctx);
        let bal = balance::zero<SUI>();
        let pix = (PixelPawn {id, owner, offers, fees: bal});
        let ownerCap = OwnerCap { id: object::new(ctx), owner };

        transfer::public_share_object(pix);
        return ownerCap
    }

    fun add_nft<T: key+store>(nft: T, pix: &mut PixelPawn, ctx: &mut TxContext) {
        let id = object::id(&nft);
        dof::add(&mut pix.id, id, nft);
    }

    fun remove_nft<T: key+store>(nft_id: ID, pix: &mut PixelPawn, ctx: &mut TxContext): T {
        dof::remove(&mut pix.id, nft_id)
    }

    public fun withdraw_balance(pix: &mut PixelPawn, cap: OwnerCap, ctx: &mut TxContext): OwnerCap{
        assert!(pix.owner == cap.owner, EIncorrenctOwner);
        let transfer_coins = pix.fees.withdraw_all();
        transfer::public_transfer(transfer_coins.into_coin(ctx), pix.owner);
        return cap
    }




    // Offer struct
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

    //Offer Getters
    public fun get_nft_id(offer: Offer): ID {
        return offer.nft_id
    }

    public fun get_pawner(offer: Offer): address {
        return offer.pawner
    }

    public fun get_lender(offer: Offer): address {
        return offer.lender
    }

    public fun get_loan_amount(offer: Offer): u64 {
        return offer.loan_amount
    }

    public fun get_interest_rate(offer: Offer): u64 {
        return offer.interest_rate
    }

    public fun get_duration(offer: Offer): u64 {
        return offer.duration
    }

    public fun get_timestamp(offer: Offer): u64 {
        return offer.timestamp
    }

    public fun get_loan_status(offer: Offer): u8 {
        return offer.loan_status
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
            nft_id,
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
        coins: Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let lender = tx_context::sender(ctx);
        let offer = pix.offers.borrow_mut(nft_id);
        assert!(offer.loan_status == 0);
        assert!(coins.value() == offer.loan_amount, EIncorrectAmount);
         
        // Update offer
        offer.lender = lender;
        offer.loan_status = 1;
        offer.timestamp = clock.timestamp_ms(); // Update timestamp to loan start time

        // Transfer funds from lender to pawner
        
        transfer::public_transfer(coins, offer.pawner);
    }

    public entry fun repay_loan <T: key+store>(
        pix: &mut PixelPawn,
        nft_id: ID,
        clock: &Clock,
        mut coins: Coin<SUI>,
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
        assert!(coins.value() == total_due, EIncorrenctPayment);
        let platform_fee = (total_due * PLATFORM_RATE)/100;
        
        // delete offer;
        let Offer {
            nft_id,
            pawner:_,
            lender,
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
        let platform_coin = coins.split(platform_fee, ctx);
        pix.fees.join(platform_coin.into_balance());
        transfer::public_transfer(coins, lender);
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