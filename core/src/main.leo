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

    const PRICE_ALEO: u64 = 20000u64; // Price format in 4 decimals, 2e4 / 20000 == $2.0000
    const PRICE_STABLE: u64 = 10000u64; // Price format in 4 decimals, 1e4 / 10000 == $1.0000

    const SECONDS_PER_BLOCK: u128 = 5u128; // Assume 5 sec per block
    const SECONDS_PER_YEAR: u128 = 31536000u128; // 60 * 60 * 24 * 365

    const RESERVE_FACTOR: u128 = 2000u128; // 20% reserve factor
    const RATE_PRECISION: u128 = 100_000_000_000u128; // 100% == 100e9, large enough for binomial approximation

    const ALEO_CREDITS_INDEX: field = 1field;
    const STABLECOIN_INDEX: field = 2field;

    const OPTIMAL_USAGE_PRECISION: u128 = 10000u128; // 100% optimal liquidity usage rate
    const OPTIMAL_USAGE_RATIO: u128 = 9000u128; // 90% optimal liquidity usage rate
    const MAX_EXCESS_USAGE_RATIO: u128 = 1000u128; // OPTIMAL_USAGE_PRECISION - OPTIMAL_USAGE_RATIO;

    // Always 0field key as global variable
    mapping total_aleo: field => u64;
    mapping total_stable: field => u64;
    // Always 0field key to track global borrow
    mapping total_borrowed_aleo: field => u64;
    mapping total_borrowed_stable: field => u64;
    // Collateral will be public
    mapping collateral_aleo: address => u64;
    mapping collateral_stable: address => u64;
    // Individual borrow tracking
    mapping borrowed_aleo: address => u64;
    mapping borrowed_stable: address => u64;
    // Indexes
    // 1field is Aleo credits
    // 2field is stablecoin
    mapping cumulative_liquidity_index: field => u128;
    mapping cumulative_borrow_index: field => u128;
    // Interest rate slopes
    // Slope 1 for < optimal usage rate
    // Slope 2 for > optimal usage rate
    // Always 0field key
    mapping interest_rate_slope1: field => u128;
    mapping interest_rate_slope2: field => u128;
    // Interest rate

    record ZALEO {
        owner: address,
        amount: u64
    }

    record ZUSD {
        owner: address,
        amount: u64
    }

    // TEMP: To get own address
    transition print_address(a: address) -> address {
        return a;
    }

    async transition deposit_credits_private(
        input: credits.aleo/credits, 
        amount: u64
        ) -> (ZALEO, credits.aleo/credits, Future) {
        // Balance check happened during transfer
        let (balance, f): (credits.aleo/credits, Future) = credits.aleo/transfer_private_to_public(
            input, 
            aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw,  // this.address
            amount
        );

        return (ZALEO {
            owner: self.caller,
            amount: amount
        }, balance, deposit_credits_private_fi(f, amount));
    }

    async function deposit_credits_private_fi(f: Future, amount: u64) {
        f.await();
        let prev_total: u64 = total_aleo.get_or_use(0field, 0u64);
        total_aleo.set(0field, prev_total + amount);
    }

    async transition deposit_stable_private(
        input: stable_usd_v0_0_0.aleo/token,
        amount: u64
        ) -> (ZUSD, stable_usd_v0_0_0.aleo/token, Future) {
        // Balance check during transfer
        let (balance, f): (stable_usd_v0_0_0.aleo/token, Future) = stable_usd_v0_0_0.aleo/transfer_private_to_public(
            input, 
            aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw, // this.address
            amount
        );

        return (ZUSD {
            owner: self.caller,
            amount: amount
        }, balance, deposit_stable_private_fi(f, amount));
    }

    async function deposit_stable_private_fi(f: Future, amount: u64) {
        f.await();
        let prev_total: u64 = total_stable.get_or_use(0field, 0u64);
        total_stable.set(0field, prev_total + amount);
    }

    async transition withdraw_credits_private(zAleo: ZALEO, amount: u64) -> (ZALEO, credits.aleo/credits, Future) {
        let remaining: u64 = zAleo.amount - amount;

        let balance: ZALEO = ZALEO {
            owner: self.caller,
            amount: remaining
        };

        let (send_back, f): (credits.aleo/credits, Future) = credits.aleo/transfer_public_to_private(
            self.caller,
            amount
        );

        return (balance, send_back, withdraw_credits_private_fi(f, amount));
    }

    async function withdraw_credits_private_fi(f: Future, amount: u64) {
        f.await();
        let prev_total: u64 = total_aleo.get(0field);
        total_aleo.set(0field, prev_total - amount);
    }

    async transition withdraw_stable_private(zUSD: ZUSD, amount: u64) -> (ZUSD, stable_usd_v0_0_0.aleo/token, Future) {
        let remaining: u64 = zUSD.amount - amount;

        let balance: ZUSD = ZUSD {
            owner: self.caller,
            amount: remaining
        };

        let (send_back, f): (stable_usd_v0_0_0.aleo/token, Future) = stable_usd_v0_0_0.aleo/transfer_public_to_private(
            self.caller,
            amount
        );

        return (balance, send_back, withdraw_stable_private_fi(f, amount));
    }

    async function withdraw_stable_private_fi(f: Future, amount: u64) {
        f.await();
        let prev_total: u64 = total_stable.get(0field);
        total_stable.set(0field, prev_total - amount);
    }

    async transition add_collateral_credits(zAleo: ZALEO, amount: u64) -> (ZALEO, Future) {
        let remaining: u64 = zAleo.amount - amount;

        return (ZALEO {
            owner: self.caller,
            amount: remaining
        }, add_collateral_credits_fi(self.caller, amount));
    }

    async function add_collateral_credits_fi(caller: address, amount: u64) {
        let prev_balance: u64 = collateral_aleo.get_or_use(caller, 0u64);
        collateral_aleo.set(caller, prev_balance + amount);
    }

    async transition add_collateral_stable(zUSD: ZUSD, amount: u64) -> (ZUSD, Future) {
        let remaining: u64 = zUSD.amount - amount;

        return (ZUSD {
            owner: self.caller,
            amount: remaining
        }, add_collateral_stable_fi(self.caller, amount));
    }

    async function add_collateral_stable_fi(caller: address, amount: u64) {
        let prev_balance: u64 = collateral_stable.get_or_use(caller, 0u64);
        collateral_stable.set(caller, prev_balance + amount);
    }

    async transition remove_collateral_credits(amount: u64) -> (ZALEO, Future) {
        return (ZALEO {
            owner: self.caller,
            amount: amount
        }, remove_collateral_credits_fi(amount, self.caller));
    }

    async function remove_collateral_credits_fi(amount: u64, caller: address) {
        // Price of Aleo $2 and price of stable $1. To be replace by external call to oracle
        // Price precision 4 decimals. To be replace by external call to oracle
        // Get collateral
        let aleo_in_usd: u64 = collateral_aleo.get_or_use(caller, 0u64) * PRICE_ALEO / PRICE_PRECISION;
        let stable_in_usd: u64 = collateral_stable.get_or_use(caller, 0u64) * PRICE_STABLE / PRICE_PRECISION;
        let total_in_usd: u64 = aleo_in_usd + stable_in_usd;

        // Get amount in USD
        let amount_in_usd: u64 = amount * PRICE_ALEO / PRICE_PRECISION;

        // Get borrowed
        let borrowed_aleo_in_usd: u64 = borrowed_aleo.get_or_use(caller, 0u64) * PRICE_ALEO / PRICE_PRECISION;
        let borrowed_stable_in_usd: u64 = borrowed_stable.get_or_use(caller, 0u64) * PRICE_STABLE / PRICE_PRECISION;
        let total_borrowed_in_usd: u64 = borrowed_aleo_in_usd + borrowed_stable_in_usd;

        // New LTV after withdraw
        let new_ltv_in_usd: u64 = (total_in_usd - amount_in_usd) * LTV_NUMERATOR / LTV_DENOMINATOR;

        // Ensure health factor is still safe after withdrawal
        assert(total_borrowed_in_usd <= new_ltv_in_usd);

        // Record new collateral
        collateral_aleo.set(caller, collateral_aleo.get(caller) - amount);
    }

    async transition borrow_credits(amount: u64) -> Future {
        // Transfer asset to borrower
        let f: Future = credits.aleo/transfer_public(self.caller, amount);
        return borrow_credits_fi(f, amount, self.caller);
    }

    async function borrow_credits_fi(f: Future, amount: u64, caller: address) {
        f.await();
        // Price of Aleo $2 and price of stable $1. To be replace by external call to oracle
        // Price precision 4 decimals. To be replace by external call to oracle
        let aleo_in_usd: u64 = collateral_aleo.get_or_use(caller, 0u64) * PRICE_ALEO / PRICE_PRECISION;
        let stable_in_usd: u64 = collateral_stable.get_or_use(caller, 0u64) * PRICE_STABLE / PRICE_PRECISION;
        let total_in_usd: u64 = aleo_in_usd + stable_in_usd;
        let max_allowed: u64 = total_in_usd * LTV_NUMERATOR / LTV_DENOMINATOR;
        let amount_in_usd: u64 = amount * PRICE_ALEO / PRICE_PRECISION;

        // Cap to max LTV
        assert(amount_in_usd <= max_allowed);

        // Record borrowed amount and new total balance
        borrowed_aleo.set(caller, amount + borrowed_aleo.get_or_use(caller, 0u64));
        total_borrowed_aleo.set(0field, amount + total_borrowed_aleo.get_or_use(0field, 0u64));
        total_aleo.set(0field, total_aleo.get(0field) - amount);
    }

    async transition borrow_stable(amount: u64) -> Future {
        // Transfer asset to borrower
        let f: Future = stable_usd_v0_0_0.aleo/transfer_public(self.caller, amount);
        return borrow_stable_fi(f, amount, self.caller);
    }

    async function borrow_stable_fi(f: Future, amount: u64, caller: address) {
        f.await();
        // Price of Aleo $2 and price of stable $1. To be replace by external call to oracle
        // Price precision 4 decimals. To be replace by external call to oracle
        let aleo_in_usd: u64 = collateral_aleo.get_or_use(caller, 0u64) * PRICE_ALEO / PRICE_PRECISION;
        let stable_in_usd: u64 = collateral_stable.get_or_use(caller, 0u64) * PRICE_STABLE / PRICE_PRECISION;
        let total_in_usd: u64 = aleo_in_usd + stable_in_usd;
        let max_allowed: u64 = total_in_usd * LTV_NUMERATOR / LTV_DENOMINATOR;
        let amount_in_usd: u64 = amount * PRICE_STABLE / PRICE_PRECISION;

        // Cap to max LTV
        assert(amount_in_usd <= max_allowed);

        // Record borrowed amount and new total balance
        borrowed_stable.set(caller, amount + borrowed_stable.get_or_use(caller, 0u64));
        total_borrowed_stable.set(0field, amount + total_borrowed_stable.get_or_use(0field, 0u64));
        total_stable.set(0field, total_stable.get(0field) - amount);
    }

    async transition repay_credits(
        input: credits.aleo/credits,
        amount: u64
        ) -> (credits.aleo/credits, Future) {
        let (balance, f): (credits.aleo/credits, Future) = credits.aleo/transfer_private_to_public(
            input, 
            aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw, // this.address
            amount
        );
        return (balance, repay_credits_fi(f, amount, self.caller));
    }

    async function repay_credits_fi(f: Future, amount: u64, caller: address) {
        f.await();
        let current_borrow: u64 = borrowed_aleo.get(caller);

        // Record repaid amount and new total balance
        borrowed_aleo.set(caller, current_borrow - amount);
        total_borrowed_aleo.set(0field, total_borrowed_aleo.get(0field) - amount);
        total_aleo.set(0field, total_aleo.get(0field) + amount);
    }

    async transition repay_stable(
        input: stable_usd_v0_0_0.aleo/token,
        amount: u64
        ) -> (stable_usd_v0_0_0.aleo/token, Future) {
        let (balance, f): (stable_usd_v0_0_0.aleo/token, Future) = stable_usd_v0_0_0.aleo/transfer_private_to_public(
            input, 
            aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw, // this.address
            amount
        );
        return (balance, repay_stable_fi(f, amount, self.caller));
    }

    async function repay_stable_fi(f: Future, amount: u64, caller: address) {
        f.await();
        let current_borrow: u64 = borrowed_stable.get(caller);

        // Record repaid amount and new total balance
        borrowed_stable.set(caller, current_borrow - amount);
        total_borrowed_stable.set(0field, total_borrowed_stable.get(0field) - amount);
        total_stable.set(0field, total_stable.get(0field) + amount);
    }

    // ========================================
    // Internal functions
    // ========================================

    // Calculate interest rate based on utilisation rate
    // All rate should follow same precision i.e. 9 decimals
    // 100% of slope_1 + slope_2 * excess usage if utilisation rate is above optimal usage rate
    // else slope_1 * utilisation rate
    // @dev Must use wrapped because of overflow, code still run and throw even `if` condition is not satisfied
    function calculate_interest(
        slope_1: u128,
        slope_2: u128,
        base_rate: u128,
        liquidity_added: u128,
        liquidity_taken: u128,
        total_liquidity: u128,
        borrowing_added: u128,
        borrowing_reduced: u128,
        total_borrowing: u128
    ) -> u128 {
        let util_rate: u128 = calculate_utilisation_rate(
            liquidity_added, 
            liquidity_taken, 
            total_liquidity, 
            borrowing_added, 
            borrowing_reduced, 
            total_borrowing
        );
        if (util_rate > OPTIMAL_USAGE_RATIO) {
            let excess: u128 = ((util_rate.sub_wrapped(OPTIMAL_USAGE_RATIO)).mul_wrapped(OPTIMAL_USAGE_PRECISION)).div_wrapped(MAX_EXCESS_USAGE_RATIO);
            return base_rate + slope_1 + (slope_2.mul_wrapped(excess)).div_wrapped(OPTIMAL_USAGE_PRECISION);
        } else {
            let util_over_optimal_rate: u128 = util_rate.mul_wrapped(OPTIMAL_USAGE_PRECISION).div_wrapped(OPTIMAL_USAGE_RATIO);
            return (base_rate + slope_1.mul_wrapped(util_over_optimal_rate).div_wrapped(OPTIMAL_USAGE_PRECISION));
        }
    }

    // Calculate current utilisation level based on liquidity and borrowing
    inline calculate_utilisation_rate(
        liquidity_added: u128,
        liquidity_taken: u128,
        total_liquidity: u128,
        borrowing_added: u128,
        borrowing_reduced: u128,
        total_borrowing: u128
    ) -> u128 {
        let liquidity: u128 = total_liquidity + liquidity_added - liquidity_taken;
        let borrowing: u128 = total_borrowing + borrowing_added - borrowing_reduced;
        let util_rate: u128 = borrowing * OPTIMAL_USAGE_PRECISION / liquidity;
        return util_rate;
    }

    // Compounded interest rate calculation is performed using a binomial approximation:
    //
    // (1+x)^n = 1+n*x+[n/2*(n-1)]*x^2+[n/6*(n-1)*(n-2)*x^3...
    function calculate_compounded_interest(
        rate: u128, // 9 decimals precision, 1% == 1_000_000_000 / 1e9
        lastBlock: u128,
        currentBlock: u128
    ) -> u128 {
        let exp: u128 = (currentBlock - lastBlock) * SECONDS_PER_BLOCK;
        if (exp == 0u128) {
            return RATE_PRECISION;
        }
        let exp_minus_one: u128 = exp - 1u128;
        let exp_minus_two: u128 = exp > 2u128 ? exp - 2u128 : 0u128;

        let numerator_two: u128 = rate * rate / RATE_PRECISION * exp * exp_minus_one;
        let numerator_three: u128 = rate * rate * rate / RATE_PRECISION / RATE_PRECISION * exp * exp_minus_one * exp_minus_two;

        let denominator_two: u128 = 2u128 * SECONDS_PER_YEAR * SECONDS_PER_YEAR;
        let denominator_three: u128 = 6u128 * SECONDS_PER_YEAR * SECONDS_PER_YEAR * SECONDS_PER_YEAR;

        let secondTerm: u128 = numerator_two / denominator_two;
        let thirdTerm: u128 = numerator_three / denominator_three;

        return RATE_PRECISION + (rate * exp) / SECONDS_PER_YEAR + secondTerm + thirdTerm;
    }

    // Interest accumulated calculated using linear rate formula
    function calculate_linear_interest(
        rate: u128, // 9 decimals precision, 1% == 1_000_000_000 / 1e9
        lastBlock: u128,
        currentBlock: u128
    ) -> u128 {
        let res: u128 = rate * ((currentBlock - lastBlock) * SECONDS_PER_BLOCK);
        res = res / SECONDS_PER_YEAR;

        return RATE_PRECISION + res;
    }
}
