// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ZenthrToken is ERC20, ERC20Burnable, Ownable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address public feeCollector;
    uint256 public constant FEE_PERCENTAGE = 5;

    constructor(address initialOwner, address _feeCollector) ERC20("Zenthr", "ZEN") Ownable(initialOwner) {
        require(_feeCollector != address(0), "Fee collector cannot be the zero address");
        require(initialOwner != address(0), "The initial owner cant be the zero address");
        feeCollector = _feeCollector;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function changeFeeCollector(address newFeeCollector ) public onlyOwner {
        feeCollector = newFeeCollector;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * FEE_PERCENTAGE) / 100;
        uint256 amountAfterFee = amount - fee;

        return super.transfer(feeCollector, fee) && super.transfer(recipient, amountAfterFee);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * FEE_PERCENTAGE) / 100;
        uint256 amountAfterFee = amount - fee;

        super.transferFrom(sender, feeCollector, fee);
        return super.transferFrom(sender, recipient, amountAfterFee);
    }
}
