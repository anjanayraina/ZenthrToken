// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ZenthrToken.sol"; // Update the path according to your project structure

contract ZenthrTokenTest is Test {
    ZenthrToken zenthrToken;
    address owner = address(1);
    address feeCollector = address(2);
    address addr1 = address(3);
    address addr2 = address(4);
    uint256 constant FEE_PERCENTAGE = 5;

    function setUp() public {
        zenthrToken = new ZenthrToken(owner, feeCollector);
    }

    function test_Minting() public {
        uint256 mintAmount = 100 ether;
        vm.prank(owner);
        zenthrToken.mint(addr1, mintAmount);
        assertEq(zenthrToken.balanceOf(addr1), mintAmount);
    }

    function testTransferFeeDeduction() public {
        uint256 mintAmount = 100 ether;
        uint256 transferAmount = 50 ether;
        uint256 expectedFee = transferAmount * FEE_PERCENTAGE / 100;
        uint256 expectedAmountAfterFee = transferAmount - expectedFee;
        vm.prank(owner);
        zenthrToken.mint(addr1, mintAmount);
        vm.prank(addr1);
        zenthrToken.transfer(addr2, transferAmount);

        assertEq(zenthrToken.balanceOf(addr2), expectedAmountAfterFee);
        assertEq(zenthrToken.balanceOf(feeCollector), expectedFee);
    }

    function testTransferFromWithFee() public {
        uint256 mintAmount = 100 ether;
        uint256 transferAmount = 20 ether;
        uint256 expectedFee = transferAmount * FEE_PERCENTAGE / 100;
        uint256 expectedAmountAfterFee = transferAmount - expectedFee;
        vm.prank(owner);
        zenthrToken.mint(addr1, mintAmount);
        vm.startPrank(addr1);
        zenthrToken.approve(owner, transferAmount);
        vm.stopPrank();

        vm.prank(owner);
        zenthrToken.transferFrom(addr1, addr2, transferAmount);

        assertEq(zenthrToken.balanceOf(addr2), expectedAmountAfterFee);
        assertEq(zenthrToken.balanceOf(feeCollector), expectedFee);
    }

    function test_ChangeFeeCollector() public {
        vm.prank(address(owner));
        zenthrToken.changeFeeCollector(address(10));
        vm.expectRevert();
        zenthrToken.changeFeeCollector(address(1));

    }

    function testFail_MintFromNonOwner() public {
    uint256 mintAmount = 100 ether;
    vm.prank(addr1); 
    zenthrToken.mint(addr2, mintAmount); 
}

}
