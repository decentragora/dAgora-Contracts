# Smart Contract Design for Sybil Resistance

Create a solidity smart contract that constructs a non-transferable NFT that represents on-chain actions performed by an address of the EVM. It must work with the Oath contract (on-chain attestation every 365 days) and the Secret Message contract (secret encrypted string passed as a message into a block), highlighting an address's behaviour on Ethereum and giving it a rank compared to other contract minters.

The actions should be aggregated, converted to human readable language, and interpreted so the transactions get grouped. It must be easy to measure an address on Ethereum and understand the controller behind it. The contract needs read functions that tell someone precisely what an address has done in a human-readable way.

It needs to check all compatible chains. It needs to filter explicit low-value transactions that fit the profile of a bot or non-human. The minimum value of transactions should be around 2.50 USD, including gas fees. Make the value updated through an oracle like Chainlink. Exclude addresses that consistently send multiple transactions in one block— a sign of a spam bot.

The contract needs to be within the memory limit of 24KB. And it needs to compute maths for an address to give it a reputation score. Finally, the contract math needs to be highly resistant to Sybil attacks, ideally using a quadratic formula— more contributions representing good things on Ethereum create a better score. 

The quadratic bonus gets defined by point accumulation for the following precursors:

**Ecosystem Actions:** 
- Address has voted in major DAOs = +1 Sybil point
- Address has voted in 3+ major DAOs = +3 Sybil points
- Address has voted in 5+ major DAOs = +5 Sybil points
- Address has voted in 7+ major DAOs = +7 Sybil points
- Address has voted in 9+ major DAOs = +9 Sybil points
- Address donated after Gitcoin round 10 = +3 Sybil points
- Address donated after Gitcoin round 5 = +5 Sybil points
- Address donated before Gitcoin round 5 = +7 Sybil points
- Address donated in first Gitcoin round = +9 Sybil points

**Transaction Amount:**
- Address has greater than 10 txns on Mainnet = +1 Sybil point
- Address has greater than 50 txns on Mainnet = +3 Sybil points 
- Address has greater than 100 txns on Mainnet = +5 Sybil points
- Address has greater than 350 txns on Mainnet = +7 Sybil points
- Address has greater than 500 txns on Mainnet = +10 Sybil points
- Address has greater than 1000 txns on Mainnet = +20 Sybil points
- Address has greater than 1500 txns on Mainnet = +25 Sybil points
- Address has greater than 2000 txns on Mainnet = +30 Sybil points
- Address has greater than 3000 txns on Mainnet = +50 Sybil points

**Transaction Age:**
- Address has transactions older than 15 days = +1 Sybil point
- Address has transactions older than 30 days = +3 Sybil points
- Address has transactions older than 60 days = +5 Sybil points
- Address has transactions older than 90 days = +7 Sybil points
- Address has transactions older than 180 days = +10 Sybil points
- Address has transactions older than 365 days = +20 Sybil points
- Address has transactions older than 730.5 days = +25 Sybil points
- Address has transactions older than 1095.75 days = +30 Sybil points
- Address has transactions older than 1826.25 days = +50 Sybil points

**DEX Usage:**
- Address has used 1 major dex with a swap value <10$ = +1 Sybil point
- Address has used 1 major dex 10 times = +3 Sybil points
- Address has used 2+ major dex(s) 10 times = +3 Sybil points
- Address has used 1 major dex 20 times = +5 Sybil points
- Address has used 2+ major dex 20 times = +5 Sybil points
- Address has used 1 major dex 30 times = +7 Sybil points
- Address has used 2+ major dex 30 times = +7 Sybil points
- Address has used 1 major dex 50 times = +10 Sybil points
- Address has used 2+ major dex 50 times = +10 Sybil points


The Sybil score relates to how many people have minted an NFT from the contract, and a complete score is derived by how many possible points an address can achieve divided by the number of achievers. The rarity of an SBT depends on how many users have claimed an NFT and hit the actionable tiers.

The contract admin needs to add actions over time to avoid a situation where no one gets awarded or too many addresses get rewards for things that are very easy to achieve. The more NFTs, the fewer points are awarded to the addresses that hit specific queries. In time, the reward per address should decrease linearly compared to users, and time passed.

For innovative purposes, the contract needs to include ways for the NFT to vote for on-chain governance proposals that change how the smart contract functions.


> Example of a readable query: 90 swap transactions via 'Uniswap' or 10 votes across X number of DAOs

> Example of an admin write function: Update address action(s) to award Sybil points to addresses <5000 days or Emergency Pause Contracts

> Example of a public write function: Renounce ownership of SBT or Upgrade SBT

> Example of a governance function: Change action(s) by majority vote, Upgrade action(s) by majority vote or Emergency Pause Contracts
