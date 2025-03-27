module StudentClubs::ClubRegistry {
    use std::signer;
    use std::vector;
    use aptos_std::table::{Self, Table};

    /// Struct representing a student club
    struct Club has store, key {
        members: vector<address>,
        president: address,
        is_verified: bool,
    }

    /// Table to store all registered clubs
    struct ClubRegistry has key {
        clubs: Table<address, Club>
    }

    /// Initialize the club registry for an account
    public fun initialize_registry(account: &signer) {
        let registry = ClubRegistry {
            clubs: table::new()
        };
        move_to(account, registry);
    }

    /// Create a new student club and register it
    public fun create_club(
        president: &signer, 
        club_address: address
    ) acquires ClubRegistry {
        let president_addr = signer::address_of(president);
        
        // Ensure the registry exists
        assert!(exists<ClubRegistry>(president_addr), 1);

        // Create a new club
        let new_club = Club {
            members: vector::singleton(president_addr),
            president: president_addr,
            is_verified: false
        };

        // Borrow the registry and add the club
        let registry = borrow_global_mut<ClubRegistry>(president_addr);
        table::add(&mut registry.clubs, club_address, new_club);
    }

    /// Verify a student club (only callable by an authorized verifier)
    public fun verify_club(
        verifier: &signer, 
        club_address: address, 
        club_president: address
    ) acquires ClubRegistry {
        // In a real-world scenario, add access control for the verifier
        let registry = borrow_global_mut<ClubRegistry>(club_president);
        
        // Retrieve and update the club
        let club = table::borrow_mut(&mut registry.clubs, club_address);
        club.is_verified = true;
    }
}