#!/bin/bash

# This script is used to test the program

# Preset PRIVATE_KEY in .env to run
# Preset balance and amount to test in this script, amount must be less than balance
balance="100_000_000u64"
amount="10_000_000u64"

echo -e "\n>>> Getting credits record <<<\n"
source .env
owner=$(leo account import $PRIVATE_KEY | awk '/Address/ {printf $2}')
echo -e "Owner = ${owner}\n"
credits_record=$(cd ../credits && leo run transfer_public_to_private ${owner} ${balance} | awk '/owner/,/_nonce/ {printf $0}')
credits_record=\"{${credits_record}}\"
echo -e "Credits Record = ${credits_record}\n"

# Test print address
echo -e "\n>>> Test print address <<<\n"
leo run print_address zlend_v0_0_0.aleo

# Test deposit_credits_private
echo -e "\n>>> Test deposit_credits_private <<<\n"
echo -e "credits_record = ${credits_record}\n"
leo run deposit_credits_private "{  owner: aleo1wsend9sju5qnp2n8hcwug5wkn99dhyaa9z0ghy62vecqs7mvmurqmavkz0.private,  microcredits: 100000000u64.private,  _nonce: 3912014721620745568731209339925199250584097142860810246990193295075541680748group.public}" ${amount}

# Test deposit_stable_private
echo -e "\n>>> Test deposit_stable_private <<<\n"
leo run deposit_stable_private "{  owner: aleo1wsend9sju5qnp2n8hcwug5wkn99dhyaa9z0ghy62vecqs7mvmurqmavkz0.private,  amount: 100000000u64.private,  _nonce: 3912014721620745568731209339925199250584097142860810246990193295075541680748group.public}" ${amount}

# Test withdraw_credits_private
echo -e "\n>>> Test withdraw_credits_private <<<\n"
leo run withdraw_credits_private "{  owner: aleo1wsend9sju5qnp2n8hcwug5wkn99dhyaa9z0ghy62vecqs7mvmurqmavkz0.private,  amount: 10000000u64.private,  _nonce: 3912014721620745568731209339925199250584097142860810246990193295075541680748group.public}" ${amount}

# Test withdraw_stable_private
echo -e "\n>>> Test withdraw_stable_private <<<\n"
leo run withdraw_stable_private "{  owner: aleo1wsend9sju5qnp2n8hcwug5wkn99dhyaa9z0ghy62vecqs7mvmurqmavkz0.private,  amount: 10000000u64.private,  _nonce: 3912014721620745568731209339925199250584097142860810246990193295075541680748group.public}" ${amount}

# Test add_collateral_credits
echo -e "\n>>> Test add_collateral_credits <<<\n"
leo run add_collateral_credits "{  owner: aleo1wsend9sju5qnp2n8hcwug5wkn99dhyaa9z0ghy62vecqs7mvmurqmavkz0.private,  amount: 10000000u64.private,  _nonce: 3912014721620745568731209339925199250584097142860810246990193295075541680748group.public}" ${amount}

# Test add_collateral_stable
echo -e "\n>>> Test add_collateral_stable <<<\n"
leo run add_collateral_stable "{  owner: aleo1wsend9sju5qnp2n8hcwug5wkn99dhyaa9z0ghy62vecqs7mvmurqmavkz0.private,  amount: 10000000u64.private,  _nonce: 3912014721620745568731209339925199250584097142860810246990193295075541680748group.public}" ${amount}

# Test borrow_credits
echo -e "\n>>> Test borrow_credits <<<\n"
leo run borrow_credits ${amount}

# Test borrow_stable
echo -e "\n>>> Test borrow_stable <<<\n"
leo run borrow_stable ${amount}

# Test repay_credits
echo -e "\n>>> Test repay_credits <<<\n"
leo run repay_credits "{  owner: aleo1wsend9sju5qnp2n8hcwug5wkn99dhyaa9z0ghy62vecqs7mvmurqmavkz0.private,  microcredits: 10000000u64.private,  _nonce: 3912014721620745568731209339925199250584097142860810246990193295075541680748group.public}" ${amount}

# Test repay_stable
echo -e "\n>>> Test repay_stable <<<\n"
leo run repay_stable "{  owner: aleo1wsend9sju5qnp2n8hcwug5wkn99dhyaa9z0ghy62vecqs7mvmurqmavkz0.private,  amount: 10000000u64.private,  _nonce: 3912014721620745568731209339925199250584097142860810246990193295075541680748group.public}" ${amount}
