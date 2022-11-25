// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../StockMarket.sol";

contract testSuite2 is StockMarket {
    address acc0 = TestsAccounts.getAccount(0);
    address acc1 = TestsAccounts.getAccount(1);
    address acc2 = TestsAccounts.getAccount(2);
    address acc3 = TestsAccounts.getAccount(3);

    constructor() StockMarket(getInitialOwners(),getInitialQuantity()){}

    function getInitialOwners() private pure returns (address[] memory){
        address[] memory initialOwners = new address[](3);
        for(uint i = 0; i < 3; i++){
            initialOwners[i] = TestsAccounts.getAccount(i+1);
        }
        return initialOwners;
    }

    function getInitialQuantity() private pure returns (uint[] memory){
        uint[] memory initialQuantities = new uint[](3);
        for(uint i = 0; i < 3; i++){
            initialQuantities[i] = i+1;
        }
        return initialQuantities;
    }

    /// #value: 200
    /// #sender: account-0
    function testBuyOrder() public payable  {
        buy (100, 2);
        Assert.equal(address(this).balance, 200,'');
        Assert.equal(buyOrders[0].issuer, acc0, 'address');
        Assert.ok(buyOrders[0].quantity == 2, 'quantity should be 2');
        Assert.ok(buyOrders[0].price == 100, 'price should be 100');
    }

    /// #sender: account-3
    function testSellOrder() public {
        uint acc3Balance = address(acc3).balance;
        sell(80, 3);
        Assert.equal(buyOrders.length, 0, '');
        Assert.equal(address(this).balance, 0,'The balance of the contract should be 0');
        Assert.equal(address(acc3).balance, acc3Balance + 200,'');
        Assert.equal(sellOrders.length,1,'');
        Assert.equal(sellOrders[0].issuer,acc3,'');
        Assert.equal(sellOrders[0].quantity,1,'');
        Assert.equal(liquidStocks[acc3], 0, '');
        Assert.equal(liquidStocks[acc0], 2, '');
    }

    /// #value: 600
    function testBuyOrder2() public payable {
        uint acc0Balance = address(acc0).balance;
        uint acc3Balance = address(acc3).balance;
        buy(200, 3);
        Assert.equal(sellOrders.length, 0, '');
        Assert.equal(address(acc3).balance, acc3Balance + 80, '');
        Assert.equal(buyOrders.length, 1, '');
        Assert.equal(buyOrders[0].quantity, 2, '');
        Assert.equal(address(acc0).balance, acc0Balance + 120, '');
    }

    /// #value: 600
    /// #sender: account-1
    function testBuyOrderOrdering() public payable {
        buy(300, 2);
        Assert.equal(buyOrders.length, 2,'');
        Assert.equal(buyOrders[0].price, 200, '');
        Assert.equal(buyOrders[1].price, 300, '');
    }

    /// #value: 100
    /// #sender: account-1
    function testBuyOrderOrdering2() public payable {
        buy(100, 1);
        Assert.equal(buyOrders.length, 3,'');
        Assert.equal(buyOrders[0].price, 100, '');
        Assert.equal(buyOrders[1].price, 200, '');
        Assert.equal(buyOrders[2].price, 300, '');
    }
}