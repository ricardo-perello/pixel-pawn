module pixelpawn::tests {
    use sui::test_scenario::{Self as ts, Scenario};
    use sui::coin::{mint_for_testing};
    use sui::sui::SUI;
    use pixelpawn::pixelpawn::{
        PixelPawn, OwnerCap, create_pixel_pawn, create_offer, withdraw_offer, accept_offer,
        repay_loan, claim_nft, withdraw_balance, get_offers_size
    };
    use pixelpawn::nfttypes::{
        mint_nft_1, mint_nft_2, mint_nft_3, NFT_1, NFT_2, NFT_3
    };
    use sui::transfer;
    use sui::object::{Self as object};
    use sui::tx_context::{Self as tx_context};
    use std::vector::{Self, empty};
    use sui::clock;

    #[test_only]
    fun test_create_pixel_pawn(): Scenario {
        let mut scenario = ts::begin(@0xA);
        let cap = create_pixel_pawn(scenario.ctx());
        transfer::public_transfer(cap, @0xA);
        scenario
    }

    #[test]
    fun check_owner() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA);
        let cap = scenario.take_from_sender<OwnerCap>();

        let mut pix = scenario.take_shared<PixelPawn>();
        assert!(pix.get_owner() == @0xA);
        ts::return_shared(pix);
        scenario.return_to_sender(cap);
        scenario.end();
    }

    // ------------------------------
    // Test create and withdraw offer
    // ------------------------------

    // Test for NFT_1
    #[test]
    fun test_create_and_withdraw_offer_nft_1() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA);
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        
        // Dummy NFT object
        let nft = mint_nft_1(100, 6, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 100, 5, 1000, scenario.ctx());
        
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
        ts::return_shared(pix);
        scenario.return_to_sender( cap);
        scenario.end();
    }

    // Test for NFT_2
    #[test]
    fun test_create_and_withdraw_offer_nft_2() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA
        );
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();

        // Mint NFT_2
        let metadata_url = b"https://example.com/metadata";
        let nft = mint_nft_2(@0xA
        , metadata_url, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 200, 7, 2000, scenario.ctx());

        assert!(pix.get_offers_size() == 1);

        let offer = pix.get_offer(nft_id);
        assert!(offer.get_nft_id() == nft_id);
        assert!(offer.get_duration() == 2000);
        assert!(offer.get_interest_rate() == 7);
        assert!(offer.get_loan_amount() == 200);
        assert!(offer.get_lender() == @0x0);
        assert!(offer.get_loan_status() == 0);
        assert!(offer.get_pawner() == tx_context::sender(scenario.ctx()));
        assert!(offer.get_timestamp() == 0);

        withdraw_offer<NFT_2>(&mut pix, nft_id, scenario.ctx());

        assert!(pix.get_offers_size() == 0);
        ts::return_shared(pix);
        scenario.return_to_sender(cap);
        scenario.end();
    }

    // Test for NFT_3
    #[test]
    fun test_create_and_withdraw_offer_nft_3() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA);
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();

        // Mint NFT_3
        let mut attributes = vector::empty<vector<u8>>();
        vector::push_back(&mut attributes, b"Attribute1");
        vector::push_back(&mut attributes, b"Attribute2");
        let nft = mint_nft_3(@0xA, attributes, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 300, 9, 3000, scenario.ctx());

        assert!(pix.get_offers_size() == 1);

        let offer = pix.get_offer(nft_id);
        assert!(offer.get_nft_id() == nft_id);
        assert!(offer.get_duration() == 3000);
        assert!(offer.get_interest_rate() == 9);
        assert!(offer.get_loan_amount() == 300);
        assert!(offer.get_lender() == @0x0);
        assert!(offer.get_loan_status() == 0);
        assert!(offer.get_pawner() == tx_context::sender(scenario.ctx()));
        assert!(offer.get_timestamp() == 0);

        withdraw_offer<NFT_3>(&mut pix, nft_id, scenario.ctx());

        assert!(pix.get_offers_size() == 0);
        ts::return_shared(pix);
        scenario.return_to_sender(cap);
        scenario.end();
    }

    // ------------------------------
    // Test accept offer
    // ------------------------------

    // Test for NFT_1
    #[test]
    fun test_accept_offer_nft_1() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA);
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let clock = sui::clock::create_for_testing(scenario.ctx()); // Access the Clock object
        
        // Dummy NFT object
        let nft = mint_nft_1(100, 6, scenario.ctx());
        let coins = mint_for_testing<SUI>(100, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 100, 5, 1000, scenario.ctx());
        
        
        accept_offer(&mut pix, nft_id, &clock, coins, scenario.ctx());
        scenario.next_tx(@0xA);
        let offer = pix.get_offer(nft_id);
        assert!(offer.get_loan_status() == 1, 1);
        assert!(offer.get_lender() == tx_context::sender(scenario.ctx()), 1);
        scenario.next_tx(@0xA);
        ts::return_shared(pix);
        scenario.return_to_sender( cap);
        scenario.end();
        sui::clock::destroy_for_testing(clock);
    }

    // Test for NFT_2
    #[test]
    fun test_accept_offer_nft_2() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA); // Pawner
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let clock = clock::create_for_testing(scenario.ctx());

        // Mint NFT_2
        let metadata_url = b"https://example.com/metadata";
        let nft = mint_nft_2(@0xA, metadata_url, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 200, 7, 2000, scenario.ctx());

        // Lender accepts offer
        scenario.next_tx(@0xA
        );
        let coins_lender = mint_for_testing<SUI>(200, scenario.ctx());
        accept_offer(&mut pix, nft_id, &clock, coins_lender, scenario.ctx());

        let offer = pix.get_offer(nft_id);
        assert!(offer.get_loan_status() == 1);
        assert!(offer.get_lender() == @0xA
        );

        ts::return_shared(pix);
        scenario.return_to_sender(cap);
        scenario.end();
        clock::destroy_for_testing(clock);
    }

    // Test for NFT_3
    #[test]
    fun test_accept_offer_nft_3() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA); // Pawner
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let clock = clock::create_for_testing(scenario.ctx());

        // Mint NFT_3
        let mut attributes = vector::empty<vector<u8>>();
        vector::push_back(&mut attributes, b"Attribute1");
        vector::push_back(&mut attributes, b"Attribute2");
        let nft = mint_nft_3(@0xA, attributes, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 300, 9, 3000, scenario.ctx());

        // Lender accepts offer
        scenario.next_tx(@0xA
        );
        let coins_lender = mint_for_testing<SUI>(300, scenario.ctx());
        accept_offer(&mut pix, nft_id, &clock, coins_lender, scenario.ctx());

        let offer = pix.get_offer(nft_id);
        assert!(offer.get_loan_status() == 1);
        assert!(offer.get_lender() == @0xA
        );

        ts::return_shared(pix);
        scenario.return_to_sender(cap);
        scenario.end();
        clock::destroy_for_testing(clock);
    }

    // ------------------------------
    // Test repay loan
    // ------------------------------

    // Test for NFT_1
    #[test]
    fun test_repay_loan_nft_1() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA);
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let clock = sui::clock::create_for_testing(scenario.ctx()); // Access the Clock object
        
        // Dummy NFT object
        let nft = mint_nft_1(100, 6, scenario.ctx());
        let coins_lender = mint_for_testing<SUI>(100, scenario.ctx());
        let coins_pawner = mint_for_testing<SUI>(100, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 100, 5, 1000, scenario.ctx());
        
        
        accept_offer(&mut pix, nft_id, &clock, coins_lender, scenario.ctx());
        scenario.next_tx(@0xA);
        repay_loan<NFT_1>(&mut pix, nft_id, &clock, coins_pawner, scenario.ctx());
        scenario.next_tx(@0xA);
        assert!(pix.get_offers_size() == 0, 1);
        ts::return_shared(pix);
        scenario.return_to_sender( cap);
        scenario.end();
        sui::clock::destroy_for_testing(clock);
    }

    // Test for NFT_2
    #[test]
    fun test_repay_loan_nft_2() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA); // Pawner
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let clock = clock::create_for_testing(scenario.ctx());

        // Mint NFT_2
        let metadata_url = b"https://example.com/metadata";
        let nft = mint_nft_2(@0xA, metadata_url, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 200, 7, 2000, scenario.ctx());

        // Lender accepts offer
        scenario.next_tx(@0xA
        );
        let coins_lender = mint_for_testing<SUI>(200, scenario.ctx());
        accept_offer(&mut pix, nft_id, &clock, coins_lender, scenario.ctx());

        // Pawner repays loan
        scenario.next_tx(@0xA);
        let repayment_amount = 200 * (10000 + 7)/10000; // Principal + interest
        let coins_pawner = mint_for_testing<SUI>(repayment_amount, scenario.ctx());
        repay_loan<NFT_2>(&mut pix, nft_id, &clock, coins_pawner, scenario.ctx());

        assert!(pix.get_offers_size() == 0);

        ts::return_shared(pix);
        scenario.return_to_sender(cap);
        scenario.end();
        clock::destroy_for_testing(clock);
    }

    // Test for NFT_3
    #[test]
    fun test_repay_loan_nft_3() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA); // Pawner
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let clock = clock::create_for_testing(scenario.ctx());

        // Mint NFT_3
        let mut attributes = vector::empty<vector<u8>>();
        vector::push_back(&mut attributes, b"Attribute1");
        vector::push_back(&mut attributes, b"Attribute2");
        let nft = mint_nft_3(@0xA, attributes, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 300, 9, 3000, scenario.ctx());

        // Lender accepts offer
        scenario.next_tx(@0xA
        );
        let coins_lender = mint_for_testing<SUI>(300, scenario.ctx());
        accept_offer(&mut pix, nft_id, &clock, coins_lender, scenario.ctx());

        // Pawner repays loan
        scenario.next_tx(@0xA);
        let repayment_amount = 300 * (10000 + 9)/10000; // Principal + interest
        let coins_pawner = mint_for_testing<SUI>(repayment_amount, scenario.ctx());
        repay_loan<NFT_3>(&mut pix, nft_id, &clock, coins_pawner, scenario.ctx());

        assert!(pix.get_offers_size() == 0);

        ts::return_shared(pix);
        scenario.return_to_sender(cap);
        scenario.end();
        clock::destroy_for_testing(clock);
    }

    // ------------------------------
    // Test claim NFT
    // ------------------------------

    // Test for NFT_1
    #[test]
    fun test_claim_nft_nft_1() {
        let mut scenario= test_create_pixel_pawn();
        scenario.next_tx(@0xA);
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let mut clock = sui::clock::create_for_testing(scenario.ctx()); // Access the Clock object
        
        // Dummy NFT object
        let nft = mint_nft_1(100, 6, scenario.ctx());
        let nft_id = object::id(&nft);
        let coins_lender = mint_for_testing<SUI>(100, scenario.ctx());
        
        create_offer(&mut pix, nft, 100, 5, 1, scenario.ctx());
        accept_offer(&mut pix, nft_id, &clock, coins_lender, scenario.ctx());
        scenario.next_tx(@0xA);
        sui::clock::increment_for_testing(& mut clock, 2);
        claim_nft<NFT_1>(&mut pix, nft_id, &clock, scenario.ctx());
        scenario.next_tx(@0xA);

        assert!(get_offers_size(&mut pix) == 0);
        ts::return_shared(pix);
        scenario.return_to_sender( cap);
        scenario.end();
        sui::clock::destroy_for_testing(clock);
    }

    // Test for NFT_2
    #[test]
    fun test_claim_nft_nft_2() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA); // Pawner
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let mut clock = clock::create_for_testing(scenario.ctx());

        // Mint NFT_2
        let metadata_url = b"https://example.com/metadata";
        let nft = mint_nft_2(@0xA, metadata_url, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 200, 7, 1, scenario.ctx());

        // Lender accepts offer
        scenario.next_tx(@0xA
        );
        let coins_lender = mint_for_testing<SUI>(200, scenario.ctx());
        accept_offer(&mut pix, nft_id, &clock, coins_lender, scenario.ctx());

        // Time passes
        clock::increment_for_testing(&mut clock, 2);

        // Lender claims NFT
        scenario.next_tx(@0xA
        );
        claim_nft<NFT_2>(&mut pix, nft_id, &clock, scenario.ctx());

        assert!(pix.get_offers_size() == 0);

        ts::return_shared(pix);
        scenario.return_to_sender(cap);
        scenario.end();
        clock::destroy_for_testing(clock);
    }

    // Test for NFT_3
    #[test]
    fun test_claim_nft_nft_3() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA); // Pawner
        let cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let mut clock = clock::create_for_testing(scenario.ctx());

        // Mint NFT_3
        let mut attributes = vector::empty<vector<u8>>();
        vector::push_back(&mut attributes, b"Attribute1");
        vector::push_back(&mut attributes, b"Attribute2");
        let nft = mint_nft_3(@0xA, attributes, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 300, 9, 1, scenario.ctx());

        // Lender accepts offer
        scenario.next_tx(@0xA
        );
        let coins_lender = mint_for_testing<SUI>(300, scenario.ctx());
        accept_offer(&mut pix, nft_id, &clock, coins_lender, scenario.ctx());

        // Time passes
        clock::increment_for_testing(&mut clock, 2);

        // Lender claims NFT
        scenario.next_tx(@0xA
        );
        claim_nft<NFT_3>(&mut pix, nft_id, &clock, scenario.ctx());

        assert!(pix.get_offers_size() == 0);

        ts::return_shared(pix);
        scenario.return_to_sender(cap);
        scenario.end();
        clock::destroy_for_testing(clock);
    }

    // ------------------------------
    // Test claim fees (withdraw balance)
    // ------------------------------

    // Test for NFT_1
    #[test]
    fun test_claim_fees_nft_1() {
        let mut scenario= test_create_pixel_pawn();
        scenario.next_tx(@0xA);
        let mut cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let clock = sui::clock::create_for_testing(scenario.ctx()); // Access the Clock object

        let nft = mint_nft_1(100, 6, scenario.ctx());
        let nft_id = object::id(&nft);
        let coins_lender = mint_for_testing<SUI>(100, scenario.ctx());
        let coins_pawner = mint_for_testing<SUI>(100, scenario.ctx());

        create_offer(&mut pix, nft, 100, 5, 1000, scenario.ctx());
        accept_offer(&mut pix, nft_id, &clock, coins_lender, scenario.ctx());
        scenario.next_tx(@0xA);
        repay_loan<NFT_1>(&mut pix, nft_id, &clock, coins_pawner, scenario.ctx());
        scenario.next_tx(@0xA);
        cap = withdraw_balance(&mut pix, cap, scenario.ctx());
        scenario.next_tx(@0xA);
        assert!(pix.get_fees() == 0);
        ts::return_shared(pix);
        scenario.return_to_sender( cap);
        scenario.end();
        sui::clock::destroy_for_testing(clock);
    }

    // Test for NFT_2
    #[test]
    fun test_claim_fees_nft_2() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA); // Owner of PixelPawn
        let mut cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let clock = clock::create_for_testing(scenario.ctx());

        // Mint NFT_2
        let metadata_url = b"https://example.com/metadata";
        let nft = mint_nft_2(@0xA, metadata_url, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 200, 7, 2000, scenario.ctx());

        // Lender accepts offer
        scenario.next_tx(@0xA
        );
        let coins_lender = mint_for_testing<SUI>(200, scenario.ctx());
        accept_offer(&mut pix, nft_id, &clock, coins_lender, scenario.ctx());

        // Pawner repays loan
        scenario.next_tx(@0xA);
        let repayment_amount = 200 * (10000 + 7)/10000;
        let coins_pawner = mint_for_testing<SUI>(repayment_amount, scenario.ctx());
        repay_loan<NFT_2>(&mut pix, nft_id, &clock, coins_pawner, scenario.ctx());

        // Owner withdraws balance
        scenario.next_tx(@0xA);
        cap = withdraw_balance(&mut pix, cap, scenario.ctx());

        assert!(pix.get_fees() == 0);
        ts::return_shared(pix);
        scenario.return_to_sender(cap);
        scenario.end();
        clock::destroy_for_testing(clock);
    }

    // Test for NFT_3
    #[test]
    fun test_claim_fees_nft_3() {
        let mut scenario = test_create_pixel_pawn();
        scenario.next_tx(@0xA); // Owner of PixelPawn
        let mut cap = scenario.take_from_sender<OwnerCap>();
        let mut pix = scenario.take_shared<PixelPawn>();
        let clock = clock::create_for_testing(scenario.ctx());

        // Mint NFT_3
        let mut attributes = vector::empty<vector<u8>>();
        vector::push_back(&mut attributes, b"Attribute1");
        vector::push_back(&mut attributes, b"Attribute2");
        let nft = mint_nft_3(@0xA, attributes, scenario.ctx());
        let nft_id = object::id(&nft);
        create_offer(&mut pix, nft, 300, 9, 3000, scenario.ctx());

        // Lender accepts offer
        scenario.next_tx(@0xA
        );
        let coins_lender = mint_for_testing<SUI>(300, scenario.ctx());
        accept_offer(&mut pix, nft_id, &clock, coins_lender, scenario.ctx());

        // Pawner repays loan
        scenario.next_tx(@0xA);
        let repayment_amount = 300 * (10000 + 9)/10000;
        let coins_pawner = mint_for_testing<SUI>(repayment_amount, scenario.ctx());
        repay_loan<NFT_3>(&mut pix, nft_id, &clock, coins_pawner, scenario.ctx());

        // Owner withdraws balance
        scenario.next_tx(@0xA);
        cap = withdraw_balance(&mut pix, cap, scenario.ctx());

        assert!(pix.get_fees() == 0);
        ts::return_shared(pix);
        scenario.return_to_sender(cap);
        scenario.end();
        clock::destroy_for_testing(clock);
    }
}
