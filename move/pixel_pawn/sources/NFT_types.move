module pixelpawn::nfttypes {

    // Existing NFT_1 struct and mint function
    public struct NFT_1 has key, store {
        id: UID,
        value: u64,
        rarity: u8, // Rarity level from 1 to 10
    }

    public fun mint_nft_1(value: u64, rarity: u8, ctx: &mut TxContext): NFT_1 {
        NFT_1 {
            id: object::new(ctx),
            value,
            rarity,
        }
    }

    // NFT_2 with a 'metadata_url' field
    public struct NFT_2 has key, store {
        id: UID,
        owner: address,
        metadata_url: vector<u8>, // URL to metadata or description
    }

    public fun mint_nft_2(owner: address, metadata_url: vector<u8>, ctx: &mut TxContext): NFT_2 {
        NFT_2 {
            id: object::new(ctx),
            owner,
            metadata_url,
        }
    }

    // NFT_3 with 'attributes' as a vector of strings
    public struct NFT_3 has key, store {
        id: UID,
        owner: address,
        attributes: vector<vector<u8>>, // List of attributes
    }

    public fun mint_nft_3(owner: address, attributes: vector<vector<u8>>, ctx: &mut TxContext): NFT_3 {
        NFT_3 {
            id: object::new(ctx),
            owner,
            attributes,
        }
    }

}
