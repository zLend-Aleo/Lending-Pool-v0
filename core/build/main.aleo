import credits.aleo;
import stable_usd_v0_0_0.aleo;
program zlend_v0_0_0.aleo;



record ZALEO:
    owner as address.public;
    amount as u64.public;

record ZUSD:
    owner as address.private;
    amount as u64.private;


mapping total_aleo:
	key as field.public;
	value as u64.public;


mapping total_stable:
	key as field.public;
	value as u64.public;


mapping total_borrowed_aleo:
	key as field.public;
	value as u64.public;


mapping total_borrowed_stable:
	key as field.public;
	value as u64.public;


mapping collateral_aleo:
	key as address.public;
	value as u64.public;


mapping collateral_stable:
	key as address.public;
	value as u64.public;


mapping borrowed_aleo:
	key as address.public;
	value as u64.public;


mapping borrowed_stable:
	key as address.public;
	value as u64.public;

function print_address:
    input r0 as address.private;
    output r0 as address.private;


function deposit_credits_private:
    input r0 as credits.aleo/credits.record;
    input r1 as u64.private;
    call credits.aleo/transfer_private_to_public r0 aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw r1 into r2 r3;
    cast self.caller r1 into r4 as ZALEO.record;
    async deposit_credits_private r3 r1 into r5;
    output r4 as ZALEO.record;
    output r2 as credits.aleo/credits.record;
    output r5 as zlend_v0_0_0.aleo/deposit_credits_private.future;

finalize deposit_credits_private:
    input r0 as credits.aleo/transfer_private_to_public.future;
    input r1 as u64.public;
    await r0;
    get.or_use total_aleo[0field] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into total_aleo[0field];


function deposit_stable_private:
    input r0 as stable_usd_v0_0_0.aleo/token.record;
    input r1 as u64.private;
    call stable_usd_v0_0_0.aleo/transfer_private_to_public r0 aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw r1 into r2 r3;
    cast self.caller r1 into r4 as ZUSD.record;
    async deposit_stable_private r3 r1 into r5;
    output r4 as ZUSD.record;
    output r2 as stable_usd_v0_0_0.aleo/token.record;
    output r5 as zlend_v0_0_0.aleo/deposit_stable_private.future;

finalize deposit_stable_private:
    input r0 as stable_usd_v0_0_0.aleo/transfer_private_to_public.future;
    input r1 as u64.public;
    await r0;
    get.or_use total_stable[0field] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into total_stable[0field];


function withdraw_credits_private:
    input r0 as ZALEO.record;
    input r1 as u64.private;
    sub r0.amount r1 into r2;
    cast self.caller r2 into r3 as ZALEO.record;
    call credits.aleo/transfer_public_to_private self.caller r1 into r4 r5;
    async withdraw_credits_private r5 r1 into r6;
    output r3 as ZALEO.record;
    output r4 as credits.aleo/credits.record;
    output r6 as zlend_v0_0_0.aleo/withdraw_credits_private.future;

finalize withdraw_credits_private:
    input r0 as credits.aleo/transfer_public_to_private.future;
    input r1 as u64.public;
    await r0;
    get total_aleo[0field] into r2;
    sub r2 r1 into r3;
    set r3 into total_aleo[0field];


function withdraw_stable_private:
    input r0 as ZUSD.record;
    input r1 as u64.private;
    sub r0.amount r1 into r2;
    cast self.caller r2 into r3 as ZUSD.record;
    call stable_usd_v0_0_0.aleo/transfer_public_to_private self.caller r1 into r4 r5;
    async withdraw_stable_private r5 r1 into r6;
    output r3 as ZUSD.record;
    output r4 as stable_usd_v0_0_0.aleo/token.record;
    output r6 as zlend_v0_0_0.aleo/withdraw_stable_private.future;

finalize withdraw_stable_private:
    input r0 as stable_usd_v0_0_0.aleo/transfer_public_to_private.future;
    input r1 as u64.public;
    await r0;
    get total_stable[0field] into r2;
    sub r2 r1 into r3;
    set r3 into total_stable[0field];


function add_collateral_credits:
    input r0 as ZALEO.record;
    input r1 as u64.private;
    sub r0.amount r1 into r2;
    cast self.caller r2 into r3 as ZALEO.record;
    async add_collateral_credits self.caller r1 into r4;
    output r3 as ZALEO.record;
    output r4 as zlend_v0_0_0.aleo/add_collateral_credits.future;

finalize add_collateral_credits:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use collateral_aleo[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into collateral_aleo[r0];


function add_collateral_stable:
    input r0 as ZUSD.record;
    input r1 as u64.private;
    sub r0.amount r1 into r2;
    cast self.caller r2 into r3 as ZUSD.record;
    async add_collateral_stable self.caller r1 into r4;
    output r3 as ZUSD.record;
    output r4 as zlend_v0_0_0.aleo/add_collateral_stable.future;

finalize add_collateral_stable:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use collateral_stable[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into collateral_stable[r0];


function remove_collateral_credits:
    input r0 as u64.private;
    cast self.caller r0 into r1 as ZALEO.record;
    async remove_collateral_credits r0 self.caller into r2;
    output r1 as ZALEO.record;
    output r2 as zlend_v0_0_0.aleo/remove_collateral_credits.future;

finalize remove_collateral_credits:
    input r0 as u64.public;
    input r1 as address.public;
    get.or_use collateral_aleo[r1] 0u64 into r2;
    mul r2 20000u64 into r3;
    div r3 10000u64 into r4;
    get.or_use collateral_stable[r1] 0u64 into r5;
    mul r5 10000u64 into r6;
    div r6 10000u64 into r7;
    add r4 r7 into r8;
    mul r0 20000u64 into r9;
    div r9 10000u64 into r10;
    get.or_use borrowed_aleo[r1] 0u64 into r11;
    mul r11 20000u64 into r12;
    div r12 10000u64 into r13;
    get.or_use borrowed_stable[r1] 0u64 into r14;
    mul r14 10000u64 into r15;
    div r15 10000u64 into r16;
    add r13 r16 into r17;
    sub r8 r10 into r18;
    mul r18 8000u64 into r19;
    div r19 10000u64 into r20;
    lte r17 r20 into r21;
    assert.eq r21 true;
    get collateral_aleo[r1] into r22;
    sub r22 r0 into r23;
    set r23 into collateral_aleo[r1];


function borrow_credits:
    input r0 as u64.private;
    call credits.aleo/transfer_public self.caller r0 into r1;
    async borrow_credits r1 r0 self.caller into r2;
    output r2 as zlend_v0_0_0.aleo/borrow_credits.future;

finalize borrow_credits:
    input r0 as credits.aleo/transfer_public.future;
    input r1 as u64.public;
    input r2 as address.public;
    await r0;
    get.or_use collateral_aleo[r2] 0u64 into r3;
    mul r3 20000u64 into r4;
    div r4 10000u64 into r5;
    get.or_use collateral_stable[r2] 0u64 into r6;
    mul r6 10000u64 into r7;
    div r7 10000u64 into r8;
    add r5 r8 into r9;
    mul r9 8000u64 into r10;
    div r10 10000u64 into r11;
    mul r1 20000u64 into r12;
    div r12 10000u64 into r13;
    lte r13 r11 into r14;
    assert.eq r14 true;
    get.or_use borrowed_aleo[r2] 0u64 into r15;
    add r1 r15 into r16;
    set r16 into borrowed_aleo[r2];
    get.or_use total_borrowed_aleo[0field] 0u64 into r17;
    add r1 r17 into r18;
    set r18 into total_borrowed_aleo[0field];
    get total_aleo[0field] into r19;
    sub r19 r1 into r20;
    set r20 into total_aleo[0field];


function borrow_stable:
    input r0 as u64.private;
    call stable_usd_v0_0_0.aleo/transfer_public self.caller r0 into r1;
    async borrow_stable r1 r0 self.caller into r2;
    output r2 as zlend_v0_0_0.aleo/borrow_stable.future;

finalize borrow_stable:
    input r0 as stable_usd_v0_0_0.aleo/transfer_public.future;
    input r1 as u64.public;
    input r2 as address.public;
    await r0;
    get.or_use collateral_aleo[r2] 0u64 into r3;
    mul r3 20000u64 into r4;
    div r4 10000u64 into r5;
    get.or_use collateral_stable[r2] 0u64 into r6;
    mul r6 10000u64 into r7;
    div r7 10000u64 into r8;
    add r5 r8 into r9;
    mul r9 8000u64 into r10;
    div r10 10000u64 into r11;
    mul r1 10000u64 into r12;
    div r12 10000u64 into r13;
    lte r13 r11 into r14;
    assert.eq r14 true;
    get.or_use borrowed_stable[r2] 0u64 into r15;
    add r1 r15 into r16;
    set r16 into borrowed_stable[r2];
    get.or_use total_borrowed_stable[0field] 0u64 into r17;
    add r1 r17 into r18;
    set r18 into total_borrowed_stable[0field];
    get total_stable[0field] into r19;
    sub r19 r1 into r20;
    set r20 into total_stable[0field];


function repay_credits:
    input r0 as credits.aleo/credits.record;
    input r1 as u64.private;
    call credits.aleo/transfer_private_to_public r0 aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw r1 into r2 r3;
    async repay_credits r3 r1 self.caller into r4;
    output r2 as credits.aleo/credits.record;
    output r4 as zlend_v0_0_0.aleo/repay_credits.future;

finalize repay_credits:
    input r0 as credits.aleo/transfer_private_to_public.future;
    input r1 as u64.public;
    input r2 as address.public;
    await r0;
    get borrowed_aleo[r2] into r3;
    sub r3 r1 into r4;
    set r4 into borrowed_aleo[r2];
    get total_borrowed_aleo[0field] into r5;
    sub r5 r1 into r6;
    set r6 into total_borrowed_aleo[0field];
    get total_aleo[0field] into r7;
    add r7 r1 into r8;
    set r8 into total_aleo[0field];


function repay_stable:
    input r0 as stable_usd_v0_0_0.aleo/token.record;
    input r1 as u64.private;
    call stable_usd_v0_0_0.aleo/transfer_private_to_public r0 aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw r1 into r2 r3;
    async repay_stable r3 r1 self.caller into r4;
    output r2 as stable_usd_v0_0_0.aleo/token.record;
    output r4 as zlend_v0_0_0.aleo/repay_stable.future;

finalize repay_stable:
    input r0 as stable_usd_v0_0_0.aleo/transfer_private_to_public.future;
    input r1 as u64.public;
    input r2 as address.public;
    await r0;
    get borrowed_stable[r2] into r3;
    sub r3 r1 into r4;
    set r4 into borrowed_stable[r2];
    get total_borrowed_stable[0field] into r5;
    sub r5 r1 into r6;
    set r6 into total_borrowed_stable[0field];
    get total_stable[0field] into r7;
    add r7 r1 into r8;
    set r8 into total_stable[0field];


closure calculate_compounded_interest:
    input r0 as u128;
    input r1 as u128;
    input r2 as u128;
    sub r2 r1 into r3;
    is.eq r3 0u128 into r4;
    sub r3 1u128 into r5;
    gt r3 2u128 into r6;
    sub r3 2u128 into r7;
    ternary r6 r7 0u128 into r8;
    mul r0 r0 into r9;
    div r9 1_000_000_000_000_000_000u128 into r10;
    mul 6307200u128 6307200u128 into r11;
    div r10 r11 into r12;
    mul r0 r12 into r13;
    div r13 1_000_000_000_000_000_000u128 into r14;
    div r14 6307200u128 into r15;
    mul r3 r5 into r16;
    mul r16 r12 into r17;
    div r17 2u128 into r18;
    mul r3 r5 into r19;
    mul r19 r8 into r20;
    mul r20 r15 into r21;
    div r21 6u128 into r22;
    mul r0 r3 into r23;
    div r23 6307200u128 into r24;
    add 1_000_000_000_000_000_000u128 r24 into r25;
    add r25 r18 into r26;
    add r26 r22 into r27;
    ternary r4 1_000_000_000_000_000_000u128 r27 into r28;
    output r28 as u128;


closure calculate_linear_interest:
    input r0 as u128;
    input r1 as u128;
    input r2 as u128;
    sub r2 r1 into r3;
    mul r0 r3 into r4;
    div r4 6307200u128 into r5;
    add 1_000_000_000_000_000_000u128 r5 into r6;
    output r6 as u128;
