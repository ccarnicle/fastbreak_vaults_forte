# aiSports: FastBreak Vaults - Flow Forte Upgrade

**An upgrade to the aiSports FastBreak Vaults dApp, integrating Flow Forte's powerful new features to enhance automation, composability, and user experience for the Flow Forte Hackathon.**

---

## 🚀 Project Overview

**aiSports** is a cutting-edge Web3 Fantasy Sports platform built on the Flow blockchain. Our existing `FastBreak Vaults` dApp allows NBA Top Shot collectors to amplify their fantasy experience by staking `$FLOW` into on-chain prize pools tied to the performance of their FastBreak lineups. The smart contracts automatically verify outcomes and distribute winnings, offering a fully transparent and decentralized fantasy sports game.

## 🧩 Core Components

-   **Core Contract:** `FastBreakEscrow.cdc` — foundational escrow and payout logic for FastBreak Vaults
-   **Hackathon Additions:**
    -   `aiSportsSwapper.cdc` — swaps supported tokens (starting with `$FLOW`) to `$JUICE`
    -   `aiSportsSwapperTransactionHandler.cdc` — scheduled handler that triggers swaps on a cadence

### Contract Links (Mainnet)
-   FastBreak Escrow: https://www.flowscan.io/contract/A.254b32edc33e5bc3.FastBreakEscrow
-   aiSportsSwapper: https://www.flowscan.io/contract/A.254b32edc33e5bc3.aiSportsSwapper
-   aiSportsSwapperTransactionHandler: https://www.flowscan.io/contract/A.254b32edc33e5bc3.aiSportsSwapperTransactionHandler


## 📣 Hackathon Entry

### Description

FastBreak Vaults by aiSports: Onchain NBA Fantasy Sports, Automated.

FastBreak Vaults transforms the NBA Top Shot fantasy experience into a high-stakes, onchain competition. Leveraging the composability of FastbreakV1 contract, our platform adds a new layer of excitement to Top Shot's "Fast Break" game by allowing users to stake `$FLOW` into shared prize pools, compete with their Fast Break lineups, and win prizes.

The rules are simple: win Fast Break and split the prize pool with other winners in proportion to your number of entries. The more entries, the more you can win!

Our mission is to merge the thrill of fantasy sports with the transparency and power of Web3, creating a seamless and trustless experience for every sports fan.

We leverage Forte Actions and Agents by using a scheduled transaction to swap all contest fees to our token `$JUICE` once a day after the contests are completed and paid out. See the "Progress During Hackathon" section for more info.

### How It Works: The Core Experience

The user journey is designed to be simple, onchain, and fully transparent:

1.  **Play Fast Break:** Users enter an NBA Top Shot Fast Break contest using their Dapper wallet.
2.  **Enter a Vault:** Users connect their (Dapper account linked) Flow wallet to our dApp and enter the daily FastBreak Vault with a 1 `$FLOW` entry fee.
3.  **On-Chain Verification:** At the end of the day's NBA games, our smart contracts directly read FastBreak onchain data to determine which fantasy lineups met the winning criteria (e.g., scoring over 100 combined points).
4.  **Automated Payouts:** The `FastBreakEscrow` contract distributes the entire prize pool proportionally to all the winners. There is no manual intervention—results and payouts are verifiable on-chain.

### Behind the Scenes: Our Token Economy

Each contest takes a 2.5% fee. These fees are automatically converted into our native `$JUICE` token once a day via an onchain scheduled transaction, creating consistent buy pressure and supporting the aiSports ecosystem.

### Targeted Bounties

Our work directly aligns with the following hackathon bounties:

-   **Best Existing Code Integration:** We have made significant, meaningful enhancements to our live, deployed FastBreak Vaults application. See "Progress During Hackathon" for a detailed breakdown.
-   **Dapper: Top Game Integration:** Our project is fundamentally a new layer of engagement built directly on top of NBA Top Shot's FastBreak game mode.
-   **Best Use of Flow Forte Actions and Workflows:** We've created a powerful, end-to-end automated workflow by chaining a Scheduled Transaction to an Increment.fi Swap Action to create real economic value.
-   **Dune Analytics Integration:** We have built and published a comprehensive Dune dashboard to provide transparent, onchain analytics for our entire platform—including the amount of `$JUICE` bought daily via our new Forte features.

### Progress During Hackathon

For Forte Hacks, we built a powerful, autonomous economic engine to support our native `$JUICE` token and the entire aiSports ecosystem. To do this, we've deployed the `aiSportsSwapper` and `aiSportsSwapperTransactionHandler` contracts. These contracts (live on mainnet) leverage Flow's Forte upgrade to create a tokenomic flywheel. Using a Scheduled Transaction, our system automatically calls the contracts on a daily schedule. The swapper contract takes the `$FLOW` fees generated from Fast Break Vault contests and uses Forte Actions from Increment.fi to swap the collected `$FLOW` into our native `$JUICE` token. This process creates consistent, daily buy-pressure for `$JUICE`, programmatically strengthening our ecosystem's economy.

---

## 🛠 Technical Architecture

This project integrates with our existing aiSports ecosystem while introducing a new, dedicated repository for the hackathon.

-   **This Repository (`fastbreak_vaults_forte`):**
    -   Contains all new Cadence smart contracts, scripts, and transactions for the hackathon.
    -   Built on the official Flow **Scheduled Transaction** scaffold.
    -   Implements all Forte-related features.
-   **aiSports Frontend:** The existing Next.js frontend, which will be updated to interact with the new smart contract features.
-   **aiSports Firebase Backend:** Our existing backend for off-chain data and game management.
-   **Flow Cresendo Repo:** Houses the original, core aiSports smart contracts.

## 📋 Getting Started (Development)

To set up the project locally for development:

1.  **Start the Flow Emulator:**
    ```bash
    flow emulator
    ```
2.  **Deploy the Contracts:**
    ```bash
    flow project deploy
    ```
3.  **Run the Frontend (from the `aiSports Frontend` repo):**
    ```bash
    npm install
    npm run dev
    ```

---

## 🔗 Links & Resources

-   **Live URL:** https://www.aisportspro.com/fastbreak
-   **Demo Video:** https://www.youtube.com/watch?v=mb-8Q12uNVY 
-   **Dune Analytics Dashboard:** https://dune.com/aisports/aisports-analytics
-   **Contracts:** See "Contract Links (Mainnet)" above