// The 'zlend_v0_0_0' program.
import credits.aleo;
import stable_usd_v0_0_0.aleo;

// Comments with ATTENTION need fix
// Comments with TO_DO waiting for implementation
// Comments with TEMP have to get removed
program zlend_v0_0_0.aleo {
    const PRICE_PRECISION: u64 = 10000u64; // 4 decimals
    const LTV_NUMERATOR: u64 = 8000u64; // 80%
    const LTV_DENOMINATOR: u64 = 10000u64; // 80%

    // Always 0field key as global variable
    mapping total_Aleo: field => u64;
    mapping total_stable: field => u64;
    // Collateral will be public
    mapping collateral_Aleo: address => u64;
    mapping collateral_stable: address => u64;
    // Always 0field key to track global borrow
    mapping total_borrowed_Aleo: field => u64;
    mapping total_borrowed_stable: field => u64;
    // Individual borrow tracking
    mapping borrowed_Aleo: address => u64;
    mapping borrowed_stable: address => u64;

    record ZAleo {
        owner: address,
        amount: u64,
        id: u8
    }

    record ZUSD {
        owner: address,
        amount: u64,
        id: u8
    }

    record DAleo {
        owner: address,
        amount: u64,
        id: u8
    }

    // TEMP: To get own address
    transition print_address(a: address) -> address {
        return a;
    }

    transition deposit_credits_private(
        input: credits.aleo/credits.record, 
        amount: u64
        ) -> (ZAleo, credits.aleo/credits.record) {
        // Balance check happened during transfer
        let balance: credits.aleo/credits = credits.aleo/transfer_private_to_public(
            input, 
            aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw,  // this.address
            amount
        );

        return (ZAleo {
            owner: self.caller,
            amount: amount,
            id: 0u8
        }, balance) then finalize (amount);
    }

    finalize deposit_credits_private(amount: u64) {
        let prev_total: u64 = total_Aleo.get_or_use(0field, 0u64);
        total_Aleo.set(0field, prev_total + amount);
    }

    transition deposit_stable_private(
        input: stable_usd_v0_0_0.aleo/token.record,
        amount: u64
        ) -> (ZUSD, stable_usd_v0_0_0.aleo/token.record) {
        // Balance check during transfer
        let balance: stable_usd_v0_0_0.aleo/token = stable_usd_v0_0_0.aleo/transfer_private_to_public(
            input, 
            aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw, // this.address
            amount
        );

        return (ZUSD {
            owner: self.caller,
            amount: amount,
            id: 1u8
        }, balance) then finalize (amount);
    }

    finalize deposit_stable_private(amount: u64) {
        let prev_total: u64 = total_stable.get_or_use(0field, 0u64);
        total_stable.set(0field, prev_total + amount);
    }

    transition withdraw_credits_private(zAleo: ZAleo, amount: u64) -> (ZAleo, credits.aleo/credits.record) {
        let remaining: u64 = zAleo.amount - amount;

        let balance: ZAleo = ZAleo {
            owner: self.caller,
            amount: remaining,
            id: 0u8
        };

        let send_back: credits.aleo/credits = credits.aleo/transfer_public_to_private(
            self.caller,
            amount
        );

        return (balance, send_back) then finalize (amount);
    }

    finalize withdraw_credits_private(amount: u64) {
        let prev_total: u64 = total_Aleo.get(0field);
        total_Aleo.set(0field, prev_total - amount);
    }

    transition withdraw_stable_private(zUSD: ZUSD, amount: u64) -> (ZUSD, stable_usd_v0_0_0.aleo/token.record) {
        let remaining: u64 = zUSD.amount - amount;

        let balance: ZUSD = ZUSD {
            owner: self.caller,
            amount: remaining,
            id: 1u8
        };

        let send_back: stable_usd_v0_0_0.aleo/token = stable_usd_v0_0_0.aleo/transfer_public_to_private(
            self.caller,
            amount
        );

        return (balance, send_back) then finalize (amount);
    }

    finalize withdraw_stable_private(amount: u64) {
        let prev_total: u64 = total_stable.get(0field);
        total_stable.set(0field, prev_total - amount);
    }

    transition add_credits_collateral(zAleo: ZAleo, amount: u64) -> ZAleo {
        let remaining: u64 = zAleo.amount - amount;

        return ZAleo {
            owner: self.caller,
            amount: remaining,
            id: 0u8
        } then finalize (self.caller, amount);
    }

    finalize add_credits_collateral(caller: address, amount: u64) {
        let prev_balance: u64 = collateral_Aleo.get_or_use(caller, 0u64);
        collateral_Aleo.set(caller, prev_balance + amount);
    }

    transition add_stable_collateral(zUSD: ZUSD, amount: u64) -> ZUSD {
        let remaining: u64 = zUSD.amount - amount;

        return ZUSD {
            owner: self.caller,
            amount: remaining,
            id: 1u8
        } then finalize (self.caller, amount);
    }

    finalize add_stable_collateral(caller: address, amount: u64) {
        let prev_balance: u64 = collateral_stable.get_or_use(caller, 0u64);
        collateral_stable.set(caller, prev_balance + amount);
    }

    // ATTENTION: To check if this fails at finalize does cross-program call still get through?
    transition withdraw_collateral_credits(
        amount: u64,
        borrowed_aleo_: u64,
        collateral_Aleo_: u64,
        collateral_stable_: u64,
        price_Aleo: u64,            // Price format in 4 decimals, e.g. 100000 == $10.0000
        price_stable: u64           // Price format in 4 decimals, e.g. 100000 == $10.0000
    ) -> credits.aleo/credits.record {
        let usd_price_Aleo: u64 = collateral_Aleo_ * price_Aleo / PRICE_PRECISION;
        let usd_price_stable: u64 = collateral_stable_ * price_stable / PRICE_PRECISION;
        let usd_price_total: u64 = usd_price_Aleo + usd_price_stable;
        let usd_price_amount: u64 = amount * price_Aleo / PRICE_PRECISION;
        let usd_price_borrowed: u64 = borrowed_aleo_ * price_Aleo / PRICE_PRECISION;
        let new_ltv: u64 = (usd_price_total - usd_price_amount) * LTV_NUMERATOR / LTV_DENOMINATOR;

        // Ensure health factor is still safe after withdrawal
        assert(usd_price_borrowed <= new_ltv);

        let r: credits.aleo/credits = credits.aleo/transfer_public_to_private(self.caller, amount);

        return r then finalize(
            amount,
            self.caller,
            borrowed_aleo_,
            collateral_Aleo_,
            collateral_stable_,
            price_Aleo,
            price_stable 
        );
    }

    finalize withdraw_collateral_credits(
        amount: u64,
        caller: address,
        borrowed_aleo_: u64,
        collateral_Aleo_: u64,
        collateral_stable_: u64,
        price_Aleo: u64,
        price_stable: u64 
        ) {
        assert_eq(borrowed_aleo_, borrowed_Aleo.get_or_use(caller, 0u64));
        assert_eq(collateral_Aleo_, collateral_Aleo.get(caller));
        assert_eq(collateral_stable_, collateral_stable.get_or_use(caller, 0u64));
        // TO_DO: assert_eq(price, oracle.aleo/price.get(asset)); 

        collateral_Aleo.set(caller, collateral_Aleo.get(caller) - amount); // Fails if underflow
    }

    transition borrow_credits(
        amount: u64,
        collateral_Aleo_: u64,
        collateral_stable_: u64,
        price_Aleo: u64,            // Price format in 4 decimals, e.g. 100000 == $10.0000
        price_stable: u64           // Price format in 4 decimals, e.g. 100000 == $10.0000
    ) -> (DAleo, credits.aleo/credits.record) {
        let usd_price_Aleo: u64 = collateral_Aleo_ * price_Aleo / PRICE_PRECISION;
        let usd_price_stable: u64 = collateral_stable_ * price_stable / PRICE_PRECISION;
        let usd_price_total: u64 = usd_price_Aleo + usd_price_stable;
        let max_allowed: u64 = usd_price_total * LTV_NUMERATOR / LTV_DENOMINATOR;
        let usd_price_amount: u64 = amount * price_Aleo / PRICE_PRECISION;

        // Cap to max
        if (usd_price_amount > max_allowed) {
            amount = max_allowed * PRICE_PRECISION / price_Aleo;
        }

        let debt: DAleo = DAleo {
            owner: self.caller,
            amount: amount,
            id: 0u8
        };

        // Will auto fail if this.amount not enough
        let borrow: credits.aleo/credits = credits.aleo/transfer_public_to_private(
            self.caller,
            amount
        );

        return (debt, borrow) then finalize (
            amount,
            self.caller,
            collateral_Aleo_,
            collateral_stable_,
            price_Aleo,
            price_stable
        );
    }

    finalize borrow_credits(
        amount: u64,
        caller: address,
        collateral_Aleo_: u64,
        collateral_stable_: u64,
        price_Aleo: u64,
        price_stable: u64 
    ) {
        assert_eq(collateral_Aleo_, collateral_Aleo.get_or_use(caller, 0u64));
        assert_eq(collateral_stable_, collateral_stable.get_or_use(caller, 0u64));
        // TO_DO: assert_eq(price, oracle.aleo/price.get(asset)); 

        borrowed_Aleo.set(caller, amount + borrowed_Aleo.get_or_use(caller, 0u64));
        total_borrowed_Aleo.set(0field, amount + total_borrowed_Aleo.get_or_use(0field, 0u64));
        total_Aleo.set(0field, total_Aleo.get(0field) - amount);
    }

    transition repay_credits(
        debt: DAleo,
        input: credits.aleo/credits.record,
        amount: u64,
        borrowed_Aleo_: u64,
    ) -> (DAleo, credits.aleo/credits.record) {
        assert(borrowed_Aleo_ - amount >= 0u64);

        let debt_balance: DAleo = DAleo {
            owner: self.caller,
            amount: debt.amount - amount,
            id: 0u8
        };

        let balance: credits.aleo/credits = credits.aleo/transfer_private_to_public(
            input, 
            aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw, // this.address
            amount
        );

        return (debt_balance, balance) then finalize (
            amount,
            self.caller,
            borrowed_Aleo_
        );
    }

    finalize repay_credits(
        amount: u64,
        caller: address,
        borrowed_Aleo_: u64
    ) {
        let current_borrow: u64 = borrowed_Aleo.get(caller);
        assert_eq(borrowed_Aleo_, current_borrow);

        borrowed_Aleo.set(caller, current_borrow - amount);
        total_borrowed_Aleo.set(0field, total_borrowed_stable.get(0field) - amount);
        total_Aleo.set(0field, total_Aleo.get(0field) + amount);
    }
}
