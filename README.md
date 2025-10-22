# aiSports: FastBreak Vaults - Flow Forte Upgrade

**An upgrade to the aiSports FastBreak Vaults dApp, integrating Flow Forte's powerful new features to enhance automation, composability, and user experience for the Flow Forte Hackathon.**

---

## 🚀 Project Overview

**aiSports** is a cutting-edge Web3 Fantasy Sports platform built on the Flow blockchain. Our existing `FastBreak Vaults` dApp allows NBA Top Shot collectors to amplify their fantasy experience by staking `$FLOW` into on-chain prize pools tied to the performance of their FastBreak lineups. The smart contracts automatically verify outcomes and distribute winnings, offering a fully transparent and decentralized fantasy sports game.

This project for the Flow Forte Hackathon focuses on a significant upgrade to FastBreak Vaults. We are leveraging the powerful new features of the Forte upgrade—specifically **Scheduled Transactions** and **Actions**—to build a more automated, efficient, and accessible platform.

The core goals of this upgrade are:
1.  **Automate Operations:** Eliminate the need for manual intervention to close daily contests and process payouts.
2.  **Enhance Composability:** Use Forte Actions to seamlessly integrate with other protocols on Flow, starting with DEXs for token swaps.
3.  **Expand Accessibility:** Allow users to enter contests with any supported token, not just `$FLOW`, dramatically improving the user experience.

## ✨ Key Features for the Forte Hackathon

This project introduces several new features built directly on the Forte upgrade:

### 1. Automated Vault Closing & Payouts
-   **Technology:** Leverages **Flow Scheduled Transactions**.
-   **Functionality:** At a predetermined time each day, a scheduled transaction will automatically execute on-chain to close the active FastBreak Vaults. It will calculate the winners, process the prize pool, and distribute the winnings without any off-chain keepers or manual triggers.

### 2. Seamless Multi-Token Entry
-   **Technology:** Leverages **Forte Actions** from on-chain DEXs.
-   **Functionality:** Users can now enter a `$FLOW`-denominated vault using other tokens (e.g., FUSD, STAX). A single, atomic transaction will call a DEX's swap Action to convert the user's token into `$FLOW` and then immediately enter them into the vault. This creates a frictionless one-click experience.

### 3. Automated Conversion to `$JUICE`
-   **Technology:** Combines **Scheduled Transactions** and **Forte Actions**.
-   **Functionality:** The automated vault-closing transaction will take the entire prize pool, use a DEX Action to convert it to our native `$JUICE` token, and then distribute the `$JUICE` to the winners. This reinforces our platform's token economy.

## 🏆 Targeted Bounties

We are strategically targeting the following bounties with this project:

-   **🥇 Best Existing Code Integration:** We are building upon our established, live aiSports dApp, making meaningful enhancements that leverage core Flow features.
-   **🥇 Best Use of Flow Forte Actions and Workflows:** Our project is a prime example of Forte's power. We use Scheduled Transactions for automation and Actions for composability, creating a powerful, automated workflow (Close Vault -> Swap Prize Pool -> Payout).
-   **🥇 Dune Analytics Integration:** We will build and link a comprehensive Dune dashboard to provide transparent, on-chain analytics for our FastBreak Vaults.
-   **Stretch Goal - KittyPunch: Build on $FROTH Challenge:** Our architecture for multi-token vaults will be extended to allow communities to create vaults denominated in their own tokens, with `$FROTH` as the primary test case.

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

-   **Live Demo URL:** [To be deployed]
-   **Demo Video:** [To be recorded]
-   **Dune Analytics Dashboard:** [Link to be added on Day 7]