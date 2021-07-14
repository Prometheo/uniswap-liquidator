pragma solidity =0.6.6;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import './IUniswapV2Pair.sol';
import './BonusPepeToken.sol';


/// @title A contract that performs a vampire attack on the uniswap v2 liquidity pool
/// @author Prometheus
/// @notice This contracts just take tokens provided by investors and redeems it on uniswap.
contract LiquidityMigrator {
    IUniswapV2Router02 public router;
    IUniswapV2Pair public pair;
    IUniswapV2Router02 public routerFork;
    IUniswapV2Pair public pairFork;
    BonusPepeToken public bonusPepeToken;
    address public admin;
    mapping(address => uint) public unclaimedBalances; // address of people who invested and their balances of LPtoken
    bool public migrationDone;

    modifier isAdmin() {
        require(msg.sender == admin, 'only an admin can make migrations');
        _;
    }
    modifier canClaimToken() {
        require(unclaimedBalances[msg.sender] >= 0, 'no unclaimed token');
        _;
    }

    constructor(
        address _router,
        address _pair,
        address _routerFork,
        address _pairFork,
        address _bonusPepeToken
    ) public {
        router = IUniswapV2Router02(_router);
        pair = IUniswapV2Pair(_pair);
        routerFork = IUniswapV2Router02(_routerFork);
        pairFork = IUniswapV2Pair(_pairFork);
        bonusPepeToken = BonusPepeToken(_bonusPepeToken);
        admin = msg.sender;
    }
    
    /// @notice this function takes a deposit amount from an investor, mints a bonusToken to them and increases their lptoken balance
    /// @param _amount the amount to be deposited by investor
    function deposit(uint _amount) external {
        require(migrationDone == false, 'migration already done');
        pair.transferFrom(msg.sender, address(this), _amount);
        bonusPepeToken.mint(msg.sender, _amount);
        unclaimedBalances[msg.sender] += _amount;
    }

    /// @notice this function performs the redemption of LpToken on uniswap and adds the liquidity to our pool
    function migration() external isAdmin {
        require(migrationDone == false, 'migration already done');
        IERC20 token0 = IERC20(pair.token0());
        IERC20 token1 = IERC20(pair.token1());
        uint totalBalance = pair.balanceOf(address(this));
        router.removeLiquidity(
            address(token0),
            address(token1),
            totalBalance,
            0,
            0,
            address(this),
            block.timestamp
        );

        uint token0Balance = token0.balanceOf(address(this));
        uint token1Balance = token1.balanceOf(address(this));
        token0.approve(address(routerFork), token0Balance);
        token1.approve(address(routerFork), token1Balance);
        routerFork.addLiquidity(
            address(token0),
            address(token1),
            token0Balance,
            token1Balance,
            token0Balance,
            token1Balance,
            address(this),
            block.timestamp
        );
        migrationDone = true;
    }
    
    /// @notice this function allows investors to claim their lptokens if they have one
    function claimLptokens() external canClaimToken {
        require(migrationDone == true, 'migration not done yet');
        uint amountToSend = unclaimedBalances[msg.sender];
        unclaimedBalances[msg.sender] = 0;
        pairFork.transfer(msg.sender, amountToSend);
    }
}
