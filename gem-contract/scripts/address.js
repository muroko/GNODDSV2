//
const Nrm = "0xF10E1Cf179A3E5Db5A63861E65c6Fd74B78432B6";

//-----------------------
//contract IterableNodeTypeMapping
const IterableNode = "0x299C92CBE1B19C7fa9aB94345Ba018F2C7AD0036";

//contract GemNodesV2
const GemToken = "0xFE5e5c4223030222c3c57490949627A2bC2F7fe1";

//contract NODERewardManager
const Token = "0x032B2d1857E53831b733C055b5564C6C3FE8f132";

//------------------------------------------------
//Address TreasuryPool
const Treasury = "0xBCC93737F83499c2764473882429Bb3675C6303c";

//Address DistributionPool (Aka: Rewards Pool)
const Distri = "0x1CC54925ca640ef2D87305f6d4Af9EEea61b3fC0";

//Address LiquidityPool
const Liquidity = "0xD1654973675be0f563D6FdA67AACB3028c225c62";

const Router = "0x60aE616a2155Ee3d9A68541Ba4544862310933d4";//JoeTrader_Router
const Native = "0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7"; //Wrapped_Avax
const Pair = "0xbcdc1b24ae8470745c769a116a0006a073d84cf5"; //Joe_LP_Token
//--------------------------------
//==// Wallets
// owner
const Owner = "0x350db736C992d907aC663Fd2D00e54728b6CBE77";

const Addresses = [ // payee 
	"0x7e4E21845ACBA9Bd12B77e11314b23F6e81963EC",
	"0x3cA49a8b38241D57501e8cBeA2c29758dDC9e556",
	"0x1C39a38674805f00E3e1567b5858Ac3910749ea9",
	"0x5b35a03528FC48fee9012ce38e61e2773b1cC5a6",
	"0x4De1A3784A7d3a2A783Ac81B480E9C63603660E5"
]
const Metamask = "0x000000000000000000000000000000000000dead"; // hardhat19

module.exports = {
	Nrm,
	Token, GemToken, Treasury, Distri, Liquidity,
	Router, Native, Pair,
	Owner, Addresses, Metamask
}

