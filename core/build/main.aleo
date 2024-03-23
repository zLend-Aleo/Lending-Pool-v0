import credits.aleo;
import stable_usd_v0_0_0.aleo;
program zlend_v0_0_0.aleo;






record ZAleo:
    owner as address.private;
    amount as u64.private;
    id as u8.private;

record ZUSD:
    owner as address.private;
    amount as u64.private;
    id as u8.private;

record DAleo:
    owner as address.private;
    amount as u64.private;
    id as u8.private;


mapping total_Aleo:
	key as field.public;
	value as u64.public;


mapping total_stable:
	key as field.public;
	value as u64.public;


mapping collateral_Aleo:
	key as address.public;
	value as u64.public;


mapping collateral_stable:
	key as address.public;
	value as u64.public;


mapping total_borrowed_Aleo:
	key as field.public;
	value as u64.public;


mapping total_borrowed_stable:
	key as field.public;
	value as u64.public;


mapping borrowed_Aleo:
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
    gte r0.microcredits r1 into r2;
    assert.eq r2 true;
    call credits.aleo/transfer_private_to_public r0 aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw r1 into r3 r4;
    cast self.caller r1 0u8 into r5 as ZAleo.record;
    async deposit_credits_private r4 r1 into r6;
    output r5 as ZAleo.record;
    output r3 as credits.aleo/credits.record;
    output r6 as zlend_v0_0_0.aleo/deposit_credits_private.future;

finalize deposit_credits_private:
    input r0 as credits.aleo/transfer_private_to_public.future;
    input r1 as u64.public;
    await r0;
    get.or_use total_Aleo[0field] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into total_Aleo[0field];


function withdraw_credits_private:
    input r0 as ZAleo.record;
    input r1 as u64.private;
    sub r0.amount r1 into r2;
    gte r2 0u64 into r3;
    assert.eq r3 true;
    cast self.caller r2 0u8 into r4 as ZAleo.record;
    call credits.aleo/transfer_public_to_private self.caller r1 into r5 r6;
    async withdraw_credits_private r6 r1 into r7;
    output r4 as ZAleo.record;
    output r5 as credits.aleo/credits.record;
    output r7 as zlend_v0_0_0.aleo/withdraw_credits_private.future;

finalize withdraw_credits_private:
    input r0 as credits.aleo/transfer_public_to_private.future;
    input r1 as u64.public;
    await r0;
    get total_Aleo[0field] into r2;
    sub r2 r1 into r3;
    set r3 into total_Aleo[0field];


function add_credits_collateral:
    input r0 as ZAleo.record;
    input r1 as u64.private;
    sub r0.amount r1 into r2;
    gte r2 0u64 into r3;
    assert.eq r3 true;
    cast self.caller r2 0u8 into r4 as ZAleo.record;
    async add_credits_collateral self.caller r1 into r5;
    output r4 as ZAleo.record;
    output r5 as zlend_v0_0_0.aleo/add_credits_collateral.future;

finalize add_credits_collateral:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use collateral_Aleo[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into collateral_Aleo[r0];


function deposit_stable_private:
    input r0 as stable_usd_v0_0_0.aleo/token.record;
    input r1 as u64.private;
    gte r0.amount r1 into r2;
    assert.eq r2 true;
    call stable_usd_v0_0_0.aleo/transfer_private_to_public r0 aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw r1 into r3 r4;
    cast self.caller r1 1u8 into r5 as ZUSD.record;
    async deposit_stable_private r4 r1 into r6;
    output r5 as ZUSD.record;
    output r3 as stable_usd_v0_0_0.aleo/token.record;
    output r6 as zlend_v0_0_0.aleo/deposit_stable_private.future;

finalize deposit_stable_private:
    input r0 as stable_usd_v0_0_0.aleo/transfer_private_to_public.future;
    input r1 as u64.public;
    await r0;
    get.or_use total_stable[0field] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into total_stable[0field];


function withdraw_stable_private:
    input r0 as ZUSD.record;
    input r1 as u64.private;
    sub r0.amount r1 into r2;
    gte r2 0u64 into r3;
    assert.eq r3 true;
    cast self.caller r2 1u8 into r4 as ZUSD.record;
    call stable_usd_v0_0_0.aleo/transfer_public_to_private self.caller r1 into r5 r6;
    async withdraw_stable_private r6 r1 into r7;
    output r4 as ZUSD.record;
    output r5 as stable_usd_v0_0_0.aleo/token.record;
    output r7 as zlend_v0_0_0.aleo/withdraw_stable_private.future;

finalize withdraw_stable_private:
    input r0 as stable_usd_v0_0_0.aleo/transfer_public_to_private.future;
    input r1 as u64.public;
    await r0;
    get total_stable[0field] into r2;
    sub r2 r1 into r3;
    set r3 into total_stable[0field];


function add_stable_collateral:
    input r0 as ZUSD.record;
    input r1 as u64.private;
    sub r0.amount r1 into r2;
    gte r2 0u64 into r3;
    assert.eq r3 true;
    cast self.caller r2 1u8 into r4 as ZUSD.record;
    async add_stable_collateral self.caller r1 into r5;
    output r4 as ZUSD.record;
    output r5 as zlend_v0_0_0.aleo/add_stable_collateral.future;

finalize add_stable_collateral:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use collateral_stable[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into collateral_stable[r0];


function borrow_credits:
    input r0 as u64.private;
    input r1 as u64.private;
    input r2 as u64.private;
    input r3 as u64.private;
    input r4 as u64.private;
    mul r1 r3 into r5;
    div r5 10000u64 into r6;
    mul r2 r4 into r7;
    div r7 10000u64 into r8;
    add r6 r8 into r9;
    mul r9 8000u64 into r10;
    div r10 10000u64 into r11;
    mul r0 r3 into r12;
    div r12 10000u64 into r13;
    gt r13 r11 into r14;
    mul r11 10000u64 into r15;
    div r15 r3 into r16;
    ternary r14 r16 r0 into r17;
    cast self.caller r17 0u8 into r18 as DAleo.record;
    call credits.aleo/transfer_public_to_private self.caller r17 into r19 r20;
    async borrow_credits r20 r17 self.caller r1 r2 r3 r4 into r21;
    output r18 as DAleo.record;
    output r19 as credits.aleo/credits.record;
    output r21 as zlend_v0_0_0.aleo/borrow_credits.future;

finalize borrow_credits:
    input r0 as credits.aleo/transfer_public_to_private.future;
    input r1 as u64.public;
    input r2 as address.public;
    input r3 as u64.public;
    input r4 as u64.public;
    input r5 as u64.public;
    input r6 as u64.public;
    await r0;
    get collateral_Aleo[r2] into r7;
    assert.eq r3 r7;
    get collateral_stable[r2] into r8;
    assert.eq r4 r8;
    get.or_use borrowed_Aleo[r2] 0u64 into r9;
    add r1 r9 into r10;
    set r10 into borrowed_Aleo[r2];
    get.or_use total_borrowed_Aleo[0field] 0u64 into r11;
    add r1 r11 into r12;
    set r12 into total_borrowed_Aleo[0field];
    get total_Aleo[0field] into r13;
    sub r13 r1 into r14;
    set r14 into total_Aleo[0field];


function repay_credits:
    input r0 as DAleo.record;
    input r1 as credits.aleo/credits.record;
    input r2 as u64.private;
    input r3 as u64.private;
    sub r3 r2 into r4;
    gte r4 0u64 into r5;
    assert.eq r5 true;
    sub r0.amount r2 into r6;
    cast self.caller r6 0u8 into r7 as DAleo.record;
    call credits.aleo/transfer_private_to_public r1 aleo1n2zmmn77wd9k2lruzlvut807t09lt23xsthxepnxtk89vyw70cqq2sdaqw r2 into r8 r9;
    async repay_credits r9 r2 self.caller r3 into r10;
    output r7 as DAleo.record;
    output r8 as credits.aleo/credits.record;
    output r10 as zlend_v0_0_0.aleo/repay_credits.future;

finalize repay_credits:
    input r0 as credits.aleo/transfer_private_to_public.future;
    input r1 as u64.public;
    input r2 as address.public;
    input r3 as u64.public;
    await r0;
    get borrowed_Aleo[r2] into r4;
    assert.eq r3 r4;
    sub r4 r1 into r5;
    set r5 into borrowed_Aleo[r2];
    get total_borrowed_stable[0field] into r6;
    sub r6 r1 into r7;
    set r7 into total_borrowed_Aleo[0field];
    get total_Aleo[0field] into r8;
    add r8 r1 into r9;
    set r9 into total_Aleo[0field];
