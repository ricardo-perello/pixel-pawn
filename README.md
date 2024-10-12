# Pixel Pawn - NFT Collateral Lending Platform on SUI (Move)

## Table of Contents

  1.	Project Overview
  2.	Features
  3.	Technology Stack
  4.  User Flow
  5.  Prerequisites
  6.  Installation
  7.  Usage
  8.  Smart Contract Architecture
  9.  Contributing
  10.  License

## Project Overview

Pixel Pawn is a decentralized NFT collateral lending platform built on the SUI blockchain using Move smart contracts. This platform allows users to pledge their NFTs as collateral in exchange for a loan from a lender, with a defined interest rate and loan duration. If the borrower fails to repay the loan within the agreed time, the lender can claim ownership of the NFT.

Pixel Pawn combines the functionality of decentralized finance (DeFi) with non-fungible tokens (NFTs), giving users the ability to unlock liquidity from their NFTs while maintaining the opportunity to retain ownership, provided they repay their loans in time.

## Features

  * Pawn NFTs: Users can use their NFTs as collateral to secure loans from lenders.
  * Lending: Lenders can offer loans with custom interest rates and loan durations.
  * Repayment Terms: Borrowers must repay the loan within the agreed period, with the added interest.
  * Collateral Transfer: If the borrower defaults on the loan, ownership of the NFT is automatically transferred to the lender.
  * Decentralized and Transparent: Powered by smart contracts on the SUI blockchain, all transactions are verifiable and trustless.
  * Frontend: An intuitive web-based interface for borrowers and lenders to interact with the smart contracts.

## Technology Stack

  * Blockchain: SUI blockchain
  * Smart Contracts: Move programming language
  * Frontend: React.js (or your frontend framework of choice)
  * Backend: Node.js, Express (or your backend framework of choice)
  * Wallet Integration: SUI-compatible wallets (e.g., Sui Wallet)

## User Flow

1.	Borrower:
  * The borrower connects their wallet and selects the NFT they wish to pawn as collateral.
  * They specify loan terms (duration, interest rate) and submit the collateral offer.
  * If a lender agrees to the terms, the loan is initiated, and the NFT is locked in the contract.
  * The borrower must repay the loan with interest before the deadline to reclaim the NFT.
2.	Lender:
  * The lender browses collateral offers from borrowers.
  * Upon finding an offer, the lender can agree to the terms and send the agreed loan amount to the borrower.
  * If the borrower fails to repay on time, the lender automatically claims ownership of the NFT.
3.	Loan Lifecycle:
  * Loan is initiated → NFT locked in the contract → Borrower repays or defaults → NFT returned or transferred.

## Prerequisites

* Node.js and npm installed
* SUI development environment
* A SUI-compatible wallet for testing (e.g., Sui Wallet)

## Installation

1.	Clone the repository:
   git clone https://github.com/your-username/pixel-pawn.git
  	cd pixel-pawn
2. Install dependencies :
      npm install
3. Set up SUI environment:
* Install the SUI CLI.
* Set up a SUI testnet account.
4. Compile Move contracts:
  sui move build
5. Deploy Move contracts
  sui move publish
6. Start backend server
  npm run start:backend
7. Start the frontend
  npm start
## Usage

1. Connect Wallet: On the frontend, users can connect their SUI-compatible wallets.
2. Pawn an NFT: A borrower selects their NFT and offers it as collateral, specifying loan terms.
3. Lend Funds: Lenders browse available collateral offers and agree to loan terms by sending funds.
4. Repay Loan: Borrowers can repay the loan through the platform, regaining ownership of their NFT.
5. Claim NFT: If a borrower defaults, the lender automatically receives the NFT as collateral.

## Smart Contract Architecture

The backend smart contracts are written in Move and deployed on the SUI blockchain. Here’s a high-level overview of the key components:

* Collateral Contract:
  * Handles the locking of the NFT as collateral.
  * Manages loan terms, including interest rates, loan durations, and repayment.
  * Ensures automatic transfer of NFT ownership if the borrower defaults.
* Loan Contract:
  * Defines the logic for issuing and repaying loans.
  * Includes interest calculations and time-based conditions.
  * Integrates with the collateral contract to lock/unlock NFTs.
  
Happy pawning! For any questions or support, feel free to raise an issue on the GitHub repository
