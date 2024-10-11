module pixelpawn::chrono_kiosk {

    use sui::object::{UID, new}; 
    use sui::clock::Clock;
    use sui::kiosk::{Kiosk, KioskOwnerCap};
    use sui::tx_context::TxContext;
    use suitears::timelock::{Timelock};

    // Errors
    const ENotUnlocked: u64 = 100;

    // Struct for ChronoKiosk that will include time-locked items
    public struct ChronoKiosk has key, store {
        id: UID,
        kiosk: Kiosk,
    }

    // Function to create a time-locked kiosk
    public fun create_kiosk(ctx: &mut TxContext): (ChronoKiosk, KioskOwnerCap) {
        let (kiosk, owner_cap) = sui::kiosk::new(ctx);
        let id = new(ctx);
        (ChronoKiosk { id, kiosk }, owner_cap)
    }

    // Function to lock an item in the kiosk with time-lock
    public fun lock_item<T: store>(kiosk: &mut ChronoKiosk, owner_cap: &KioskOwnerCap, item: T, unlock_time: u64, c: &Clock, ctx: &mut TxContext) {
        let timelocked_item = suitears::timelock::lock(item, c, unlock_time, ctx);
        sui::kiosk::place(&mut kiosk.kiosk, owner_cap, timelocked_item);
    }

    // // Function to unlock and withdraw the item, ensuring the value is transferred to the caller
    // public fun unlock_and_withdraw<T: store>(kiosk: &mut ChronoKiosk, owner_cap: &KioskOwnerCap, item_id: UID, c: &Clock, _ctx: &mut TxContext): T {
    //     let timelocked_item: Timelock<T> = sui::kiosk::take(&mut kiosk.kiosk, owner_cap, item_id.as_inner());

    //     // Unlock the item by removing the time-lock (passing the value, not reference)
    //     let unlocked_item = suitears::timelock::unlock(timelocked_item, c);

    //     // No need to consume item_id since it's passed directly and not dropped
    //     // Return the unlocked item to the caller
    //     unlocked_item
    // }

    // // Optional: Custom error checking for unlock time and item retrieval
    // public fun withdraw_locked_item<T: store>(kiosk: &mut ChronoKiosk, owner_cap: &KioskOwnerCap, item_id: UID, c: &Clock): T {
    //     // Use sui::kiosk::take instead of borrow to get the value, not reference
    //     let timelocked_item: Timelock<T> = sui::kiosk::take(&mut kiosk.kiosk, owner_cap, item_id.as_inner());

    //     // Ensure the unlock time has passed before allowing withdrawal
    //     assert!(c.timestamp_ms() >= suitears::timelock::unlock_time(&timelocked_item), ENotUnlocked);

    //     // Unlock the item and return it
    //     suitears::timelock::unlock(timelocked_item, c)
    // }
}