module pixelpawn::tests {
    use sui::tx_context::{Self, TxContext};
    use sui::clock::{Self, Clock};
    use sui::test_scenario::{Self as ts, Scenario};
    use sui::coin::{Coin, mint_for_testing};
    use sui::sui::SUI;
    use pixelpawn::pixelpawn::{PixelPawn, create_pixel_pawn, create_offer, withdraw_offer, accept_offer, repay_loan, claim_nft};
    use pixelpawn::nfttypes::mint_nft_1;
    use pixelpawn::nfttypes::NFT_1;
    use pixelpawn::pixelpawn::Offer;
    use pixelpawn::pixelpawn::OwnerCap;

    #[test_only]
    fun test_create_pixel_pawn(): (Scenario, OwnerCap) {
        let mut scenario = ts::begin(@0xA);
        let cap = create_pixel_pawn(scenario.ctx());
        (scenario,cap)
    }

    #[test]
    fun check_owner(){
        let (mut scenario, cap) = test_create_pixel_pawn();
        scenario.next_tx(@0xA);
        let pix = scenario.take_shared<PixelPawn>();
        assert!(pix.get_owner() == @0xA);
        ts::return_shared(pix);
        scenario.end();
    }

    #[test]
    fun test_create_and_withdraw_offer() {
        let (mut scenario, cap) = test_create_pixel_pawn();
        scenario.next_tx(@0xA);
        let pix = scenario.take_shared<PixelPawn>();
        
        // Dummy NFT object
        let nft = mint_nft_1(100, 6, scenario.ctx());
        
        create_offer(&mut pix, nft, 100, 5, 1000, scenario.ctx());
        let nft_id = object::id(&nft);
        assert!(pix.get_offers_size() == 1);

        let offer = pix.get_offer(nft_id);
        assert!(offer.get_nft_id() == nft_id);
        assert!(offer.get_duration() == 1000);
        assert!(offer.get_interest_rate() == 5);
        assert!(offer.get_loan_amount() == 100);
        assert!(offer.get_lender() == @0x0);
        assert!(offer.get_loan_status() == 0);
        assert!(offer.get_pawner() == tx_context::sender(scenario.ctx()));
        assert!(offer.get_timestamp() == 0);

        
        withdraw_offer<NFT_1>(&mut pix, nft_id, scenario.ctx());
        assert!(pix.get_offers_size() == 0);
    }

    #[test]
    fun test_accept_offer() {
        let mut ts = ts::begin(@0xA);
        let mut ctx = ts.ctx();
        let clock = Clock::new(ctx);
        let mut pixel_pawn = create_pixel_pawn(ctx);
        
        // Dummy NFT object
        let nft = object::new(ctx);
        let mut coins = mint_for_testing<SUI>(200, ctx);
        
        create_offer(&mut pixel_pawn, nft, 100, 5, 1000, ctx);
        let nft_id = object::id(&nft);
        
        accept_offer(&mut pixel_pawn, nft_id, &clock, &mut coins, ctx);
        let offer = pixel_pawn.offers.borrow(nft_id);
        assert!(offer.loan_status == 1, 1);
    }

    #[test]
    fun test_repay_loan() {
        let mut ts = ts::begin(@0xA);
        let mut ctx = ts.ctx();
        let clock = Clock::new(ctx);
        let mut pixel_pawn = create_pixel_pawn(ctx);
        
        // Dummy NFT object
        let nft = object::new(ctx);
        let mut coins = mint_for_testing<SUI>(200, ctx);
        
        create_offer(&mut pixel_pawn, nft, 100, 5, 1000, ctx);
        let nft_id = object::id(&nft);
        
        accept_offer(&mut pixel_pawn, nft_id, &clock, &mut coins, ctx);
        repay_loan(&mut pixel_pawn, nft_id, &clock, &mut coins, ctx);
        assert!(pixel_pawn.offers.is_empty(), 1);
    }

    #[test]
    fun test_claim_nft() {
        let mut ts = ts::begin(@0xA);
        let mut ctx = ts.ctx();
        let clock = Clock::new(ctx);
        let mut pixel_pawn = create_pixel_pawn(ctx);
        
        // Dummy NFT object
        let nft = object::new(ctx);
        
        create_offer(&mut pixel_pawn, nft, 100, 5, 1000, ctx);
        let nft_id = object::id(&nft);
        
        accept_offer(&mut pixel_pawn, nft_id, &clock, &mut coins, ctx);
        claim_nft(&mut pixel_pawn, nft_id, &clock, ctx);
        assert!(pixel_pawn.offers.is_empty(), 1);
    }

    #[test]
    fun test_claim_fees() {
        let (mut scenario, cap) = test_create_pixel_pawn();
        scenario.next_tx(@0xA);
        let pix = scenario.take_shared<PixelPawn>();
        let clock = Clock::create(scenario.ctx());

        let nft = mint_nft_1(100, 6, scenario.ctx());
        let nft_id = object::id(&nft);
        let coins_lender = Coin<SUI>::;
        let coins_pawner = Coin<SUI>::;

        create_offer(&mut pix, nft, 100, 5, 1000, scenario.ctx());
        accept_offer(&mut pix, nft_id, &clock, &mut coins_lender, scenario.ctx());
        repay_loan(&mut pix, nft_id, &clock, &mut coins_pawner, scenario.ctx());
        withdraw_balance(&mut pix, cap, scenario.ctx())
        
    }
}
