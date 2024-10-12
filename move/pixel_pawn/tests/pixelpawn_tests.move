module pixelpawn::tests {
    use sui::tx_context::{Self, TxContext};
    use sui::clock::Clock;
    use sui::test_scenario::{Self as ts, Scenario};
    use pixelpawn::pixelpawn::{PixelPawn, create_pixel_pawn, create_offer, accept_offer, repay_loan, claim_nft};

    #[test]
    fun test_create_pixel_pawn() {
        let mut ctx = tx_context::dummy();
        let pixel_pawn = create_pixel_pawn(&mut ctx);
        assert!(pixel_pawn.offers.is_empty(), 1);
    }

    #[test]
    fun test_create_offer() {
        let mut ts = ts::begin(@0xA);
        let mut ctx = ts.ctx();
        let clock = Clock::new(ctx);
        let mut pixel_pawn = create_pixel_pawn(ctx);
        
        // Dummy NFT object
        let nft = object::new(ctx);
        
        create_offer(&mut pixel_pawn, nft, 100, 5, 1000, &clock, ctx);
        assert!(pixel_pawn.offers.size() == 1, 1);
    }

    #[test]
    fun test_accept_offer() {
        let mut ts = ts::begin(@0xA);
        let mut ctx = ts.ctx();
        let clock = Clock::new(ctx);
        let mut pixel_pawn = create_pixel_pawn(ctx);
        
        // Dummy NFT object
        let nft = object::new(ctx);
        
        create_offer(&mut pixel_pawn, nft, 100, 5, 1000, &clock, ctx);
        let nft_id = object::id(&nft);
        
        accept_offer(&mut pixel_pawn, nft_id, &clock, ctx);
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
        
        create_offer(&mut pixel_pawn, nft, 100, 5, 1000, &clock, ctx);
        let nft_id = object::id(&nft);
        
        accept_offer(&mut pixel_pawn, nft_id, &clock, ctx);
        repay_loan(&mut pixel_pawn, nft_id, &clock, ctx);
        let offer = pixel_pawn.offers.borrow(nft_id);
        assert!(offer.repayment_status == 1, 1);
    }

    #[test]
    fun test_claim_nft() {
        let mut ts = ts::begin(@0xA);
        let mut ctx = ts.ctx();
        let clock = Clock::new(ctx);
        let mut pixel_pawn = create_pixel_pawn(ctx);
        
        // Dummy NFT object
        let nft = object::new(ctx);
        
        create_offer(&mut pixel_pawn, nft, 100, 5, 1000, &clock, ctx);
        let nft_id = object::id(&nft);
        
        accept_offer(&mut pixel_pawn, nft_id, &clock, ctx);
        claim_nft(&mut pixel_pawn, nft_id, &clock, ctx);
        let offer = pixel_pawn.offers.borrow(nft_id);
        assert!(offer.repayment_status == 2, 1);
    }
}
