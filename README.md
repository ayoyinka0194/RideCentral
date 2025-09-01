 RideCentral

A decentralized autonomous organization (DAO) for ridesharing where drivers and riders collectively own and govern the platform through STXbased governance tokens.

 Overview

RideCentral revolutionizes the ridesharing industry by creating a platform owned and governed by its users. Unlike traditional centralized platforms, RideCentral distributes ownership, governance rights, and profits among drivers and riders through blockchainbased tokens.

 Features

 🚗 Decentralized Governance
 Tokenbased voting system for platform decisions
 Proposal creation and voting mechanisms
 Democratic decisionmaking for fee structures and platform changes

 💰 Profit Sharing
 Platform fees distributed as governance tokens
 Proportional profit sharing based on token holdings
 Incentivized participation through token rewards

 👥 Member Management
 Driver and rider registration system
 Reputation scoring mechanism
 Rolebased token allocation

 🔄 Ride Management
 Onchain ride completion tracking
 Automatic fee calculation and distribution
 Transparent transaction records

 Smart Contract Functions

 Token Management
 minttokens: Create new governance tokens
 transfer: Transfer tokens between accounts
 getbalance: Check token balance
 gettotalsupply: View total token supply

 Membership
 joinasdriver: Register as a driver member
 joinasrider: Register as a rider member
 getmemberinfo: Retrieve member details
 ismember: Check membership status

 Governance
 createproposal: Submit governance proposals
 vote: Cast votes on proposals
 getproposal: View proposal details
 getproposalcount: Get total number of proposals

 Ride Operations
 completeride: Record completed rides
 getriderecord: View ride details
 getridecount: Get total number of rides

 Platform Management
 updateplatformfee: Adjust platform fee rates
 distributeprofits: Distribute platform profits
 getplatformfeerate: View current fee rate

 Getting Started

 Prerequisites
 Clarinet CLI installed
 Stacks wallet for testing

 Installation
1. Clone the repository
2. Run clarinet check to verify contract syntax
3. Use clarinet console for interactive testing
4. Deploy with clarinet deploy

 Testing
bash
clarinet check
clarinet test


 Governance Model

RideCentral operates on a tokenweighted voting system where:
 Each token represents one vote
 Proposals require minimum token holdings to create
 Voting periods last approximately 10 days (1440 blocks)
 Platform decisions are made collectively by the community

 Tokenomics

 Initial Driver Allocation: 1,000 tokens
 Initial Rider Allocation: 500 tokens
 Platform Fee: 2.5% (adjustable via governance)
 Fee Distribution: 50% to drivers, 50% to riders as tokens

 Security Features

 Owneronly functions for critical operations
 Member verification for all platform interactions
 Voting period enforcement
 Doublevoting prevention
 Balance validation for all transfers

 Contributing

RideCentral is a communitydriven project. Participate by:
1. Joining as a driver or rider
2. Participating in governance votes
3. Submitting improvement proposals
4. Contributing to platform development

 License

This project is opensource and available under the MIT License.

 Contact

For questions or support, please create an issue in this repository or participate in our governance discussions.