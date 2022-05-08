// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";
import "./PaymentSplitter.sol";
import "./SafeMath.sol";
import "./IJoeRouter02.sol";
import "./IJoeFactory.sol";
import "./NODERewardManager.sol";

import "hardhat/console.sol";

contract GemNodesV2 is ERC20, Ownable, PaymentSplitter {
    using SafeMath for uint256;

    NODERewardManager public nodeRewardManager;

    IJoeRouter02 public uniswapV2Router;

    address public uniswapV2Pair;
    address public treasuryUsePool;
    address public distributionPool;
    address public liquidityPool;

    uint256 public rewardsFee;
    uint256 public liquidityPoolFee;
    uint256 public treasuryFee;
    uint256 public totalFees;

    uint256 public cashoutFee;

    uint256 public rwSwap;
    bool private swapping = false;
    bool private swapLiquify = true;
    uint256 public swapTokensAmount;

    uint256 public maxTx = 0;
    bool private tradingOpen = false;

    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public _isSuper;

    event UpdateUniswapV2Router(
        address indexed newAddress,
        address indexed oldAddress
    );

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event LiquidityWalletUpdated(
        address indexed newLiquidityWallet,
        address indexed oldLiquidityWallet
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor(
        address[] memory payees,
        uint256[] memory shares,
        address[] memory addresses,
        uint256[] memory balances,
        uint256[] memory fees,
        uint256 swapAmount,
        address uniV2Router
    ) ERC20("GemNodesV2", "GEM") PaymentSplitter(payees, shares) {
        treasuryUsePool = addresses[1];
        distributionPool = addresses[2];
		liquidityPool = addresses[3];

        require(treasuryUsePool != address(0) && distributionPool != address(0) && liquidityPool != address(0), "TREASURY, REWARD & POOL ADDRESS CANNOT BE ZERO");

        require(uniV2Router != address(0), "ROUTER CANNOT BE ZERO");
        IJoeRouter02 _uniswapV2Router = IJoeRouter02(uniV2Router);

        address _uniswapV2Pair = IJoeFactory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WAVAX());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        require(
            fees[0] != 0 && fees[1] != 0 && fees[2] != 0 && fees[3] != 0,
            "CONSTR: Fees equal 0"
        );
        treasuryFee = fees[0];
        rewardsFee = fees[1];
        liquidityPoolFee = fees[2];
        cashoutFee = fees[3];
        rwSwap = fees[4];

        totalFees = rewardsFee.add(liquidityPoolFee).add(treasuryFee);

        require(addresses.length > 0 && balances.length > 0, "CONSTR: addresses array length must be greater than zero");
        require(addresses.length == balances.length, "CONSTR: addresses arrays length mismatch");

        for (uint256 i = 0; i < addresses.length; i++) {
            _mint(addresses[i], balances[i] * (10**18));
			_isSuper[addresses[i]] = true;
        }

        //console.logString('---------------');
        //console.log(balanceOf(addresses[7]));
        //console.logString('---------------');

        require(totalSupply() == 500000e18, "CONSTR: totalSupply must equal 500K");
        require(swapAmount > 0, "CONSTR: Swap amount incorrect");
        swapTokensAmount = swapAmount * (10**18);
    }

	function increaseLiquidityDistribution(uint256 amount) external onlyOwner {
		require(amount > 0, "Amount too low");
		_mint(distributionPool, amount);
	}

    function setNodeManagement(address payable nodeManagement) external onlyOwner {
        nodeRewardManager = NODERewardManager(nodeManagement);
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "TKN: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IJoeRouter02(newAddress);
        address _uniswapV2Pair = IJoeFactory(uniswapV2Router.factory())
        .createPair(address(this), uniswapV2Router.WAVAX());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function updateSwapTokensAmount(uint256 newVal) external onlyOwner {
        swapTokensAmount = newVal;
    }

    function updateTreasuryWall(address payable wall) external onlyOwner {
        treasuryUsePool = wall;
    }

    function updateRewardsWall(address payable wall) external onlyOwner {
        distributionPool = wall;
    }

    function updateRewardsFee(uint256 value) external onlyOwner {
        rewardsFee = value;
        totalFees = rewardsFee.add(liquidityPoolFee).add(treasuryFee);
    }

    function updateLiquiditFee(uint256 value) external onlyOwner {
        liquidityPoolFee = value;
        totalFees = rewardsFee.add(liquidityPoolFee).add(treasuryFee);
    }

    function updateTreasuryFee(uint256 value) external onlyOwner {
        treasuryFee = value;
        totalFees = rewardsFee.add(liquidityPoolFee).add(treasuryFee);
    }

    function updateCashoutFee(uint256 value) external onlyOwner {
        cashoutFee = value;
    }

    function updateRwSwapFee(uint256 value) external onlyOwner {
        rwSwap = value;
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
    public
    onlyOwner
    {
        require(
            pair != uniswapV2Pair,
            "TKN: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }

    function blacklistMalicious(address account, bool value)
    external
    onlyOwner
    {
        _isBlacklisted[account] = value;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "TKN: Automated market maker pair is already set to that value"
        );
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], "Blacklisted address");
		if (from != owner() && to != owner() && from != address(this) && to != address(this) && !_isSuper[from] && !_isSuper[to] && to != uniswapV2Pair && to != address(uniswapV2Router)) {
			if (tradingOpen) {
				uint256 walletBalance = balanceOf(address(to));
				require(amount.add(walletBalance) <= maxTx, "Transfer amount too high");
			}
			if (!tradingOpen && from == uniswapV2Pair) {
				_isBlacklisted[to] = true;
			}
		}
        super._transfer(from, to, amount);
    }

    function swapAndSendToFee(address destination, uint256 tokens) private {
        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(tokens);
        uint256 newBalance = (address(this).balance).sub(initialETHBalance);
        payable(destination).transfer(newBalance);
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WAVAX();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForAVAXSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityAVAX{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityPool,
            block.timestamp
        );
    }

    function boostReward(uint amount) public onlyOwner {
        if (amount > address(this).balance) amount = address(this).balance;
        payable(owner()).transfer(amount);
    }

    function changeSwapLiquify(bool newVal) public onlyOwner {
        swapLiquify = newVal;
    }

	function openTrading(bool value) external onlyOwner {
        require(!tradingOpen,"Set to Open or Close the Trading");
        tradingOpen = value;
    }
    
	function updateMaxTx(uint256 newMaxTx) external onlyOwner {
        maxTx = newMaxTx;
    }
	
	function setIsSuper(address account, bool value) external onlyOwner {
        _isSuper[account] = value;
    }
    //function swapOld(uint256 _amount) public {
    //    address old = 0x18Da988dc5A4F449A832B51ea8A6f55031E12D0d;
    //    address dead = 0x000000000000000000000000000000000000dEaD;
    //   IERC20(old).transferFrom(msg.sender, dead, _amount);
    //    super._transfer(distributionPool, msg.sender, _amount);
    //}
}
