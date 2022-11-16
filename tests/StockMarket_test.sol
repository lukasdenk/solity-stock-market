// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../StockMarket.sol";

contract testSuite2{
    StockMarket stockMarket;
    address[] stockOwners;

    function beforeEach() public {
        stockOwners[0] = TestsAccounts.getAccount(0);
        stockOwners[1] = TestsAccounts.getAccount(1);
        stockOwners[2] = TestsAccounts.getAccount(2);

        Assert.ok(2==2,'eee');
        uint[] memory quantities = new uint[](3);
        quantities[0] = 1;
        quantities[1] = 5;
        quantities[2] = 2;StockMarket.Order[] memory buyOrders = stockMarket.getBuyOrders();
        Assert.ok(buyOrders[0].quantity == 2, 'quantity should be 2');
        stockMarket = new StockMarket(stockOwners, quantities);
    }

    /// #value: 200
    function testSingleBuyOrder() public payable  {
        stockMarket.buy{value: 200, gas:100000} (100, 2);
        StockMarket.Order[] memory buyOrders = stockMarket.getBuyOrders();
        Assert.ok(buyOrders[0].quantity == 2, 'quantity should be 2');
    }

    /// #value: 200
    function testBuyOnceThenSellAllAtOnce() public payable  {
        stockMarket.buy{value: 200, gas:100000} (100, 2);

        ///sender: account-2
        stockMarket.sell(180,2);
        Assert.equal(stockMarket.getLiquidQuantity(stockOwners[1]), 2, 'Account 1 should have bought 2 stocks.');
        Assert.equal(stockMarket.getBuyOrders().length, 0, 'All buy orders should have been fulfilled.');
    }



    function testbuyOrders() public {
        StockMarket.Order[] memory buyOrders = stockMarket.getBuyOrders();
        Assert.ok(buyOrders.length == 0,'not cool');
    }
}