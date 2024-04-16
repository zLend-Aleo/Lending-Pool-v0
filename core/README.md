# zlend_v000.aleo

## Build Guide

To compile this Aleo program, run:
```bash
snarkvm build
```

To execute this Aleo program, run:
```bash
snarkvm run hello
```
## Local Test

1. Deposit credits 
curl http://localhost:3030/mainnet/transaction/at1std94ldfpw4h7jhhutt275l5qtfyflkrm6texh602703p405dqyq80wjcf

2. Add credits collateral
curl http://localhost:3030/mainnet/transaction/at1tct32lh38chekn7r6uktyvmsngj2q6xxkedjvs6ddym9zgchks8qdvsqc9

3. Deposit stables
curl http://localhost:3030/mainnet/transaction/at1g7u0faaeg6a4cuuwqzrahd04ehfyhxzsgyde82l85dgs60vz4qzsgaxdsa

4. Borrow stables
curl http://localhost:3030/mainnet/transaction/at1693ymft3twclxll4m36lw75adq6u8xynfc2huzgkzt9w870htyrs8qdnxv

5. Repay stables
curl http://localhost:3030/mainnet/transaction/at1s5lmgas22mn9ns7qt80w57qmvunvdrfrluda7399t7f65amumyxqk4phgc

6. Check stats
Total borrowed stable = curl http://localhost:3030/mainnet/program/zlend_v0_0_0.aleo/mapping/total_borrowed_stable/0field          
Borrowed stable user = curl http://localhost:3030/mainnet/program/zlend_v0_0_0.aleo/mapping/borrowed_stable/aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px  
Total stable in program = curl http://localhost:3030/mainnet/program/zlend_v0_0_0.aleo/mapping/total_stable/0field     