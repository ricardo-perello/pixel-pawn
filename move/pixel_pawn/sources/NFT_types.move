module pixelpawn::nfttypes {

    // NFT_1 with an added 'rarity' field
    public struct NFT_1 has key, store {
        id: UID,
        value: u64,
        rarity: u8, // Rarity level from 1 to 10
    }

    // NFT_2 with a 'metadata_url' field
    public struct NFT_2 has key, store {
        id: UID,
        owner: address,
        metadata_url: vector<u8>, // URL to metadata or description
    }

    // NFT_3 with 'attributes' as a vector of strings
    public struct NFT_3 has key, store {
        id: UID,
        owner: address,
        attributes: vector<vector<u8>>, // List of attributes
    }

    public fun mint_nft_1(value: u64, rarity: u8, ctx: &mut TxContext): NFT_1 {
        NFT_1 {
            id: object::new(ctx),
            value,
            rarity,
        }
    }

}