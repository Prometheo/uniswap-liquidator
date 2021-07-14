pragma solidity =0.6.6;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract BonusPepeToken is ERC20 {
    address public admin;
    address public liquidator;
    constructor() ERC20('Bonus PepeToken', 'BPT') public {
        admin = msg.sender;
    }

    modifier isAdmin() {
        require(msg.sender == admin, 'only an admin can set liquidator');
        _;
    }
    modifier isLiquidator() {
        require(msg.sender == liquidator, 'only a liquidator can mint');
        _;
    }
    
    function setLiquidator(address _liquidator) external isAdmin {
        liquidator = _liquidator;
    }

    function mint(address _to, uint _amount) external isLiquidator {
        _mint(_to, _amount);
    }
}