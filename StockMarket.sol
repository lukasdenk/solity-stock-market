contract StockMarket {

    struct Order{
        address issuer;
        uint price;
        uint quantity;
        uint validUntilBlock;
    }

    Order[] private buyOrders;
    Order[] private sellOrders;

    mapping(address => uint) liquidStocks;


    constructor(address[] memory owners, uint[] memory quantities) {
        for(uint i=0; i<owners.length;i++){
            liquidStocks[owners[i]] = quantities[i];
        }
    }


    function buy(uint price, uint quantity, uint validUntilBlock) public payable {
        require(validUntilBlock >= block.number);
        require(msg.value==price * quantity);

        Order memory buyOrder = Order(msg.sender, price, quantity, validUntilBlock);

        while(buyOrder.quantity > 0 && sellOrders.length > 0){
            Order storage sellOrder = sellOrders[sellOrders.length - 1];
            if(sellOrder.validUntilBlock < block.number){
                sellOrders.pop();
                liquidStocks[sellOrder.issuer] += sellOrder.quantity;
            } else if(sellOrder.price > buyOrder.price){
                break;
            } else
            {
                executeOrders(sellOrder, buyOrder, buyOrder.price);
                if(sellOrder.quantity == 0){
                    sellOrders.pop();
                }
            }
        }

        if(buyOrder.quantity > 0){
            addToBuyOrders(buyOrder);
        }
    }


    function sell(uint price, uint quantity, uint validUntilBlock) public {
        require(validUntilBlock >= block.number);
        require(liquidStocks[msg.sender] >= quantity);

        Order memory sellOrder = Order(msg.sender, price, quantity, validUntilBlock);
        liquidStocks[msg.sender] -= quantity;

        while(sellOrder.quantity > 0 && buyOrders.length > 0){
            Order memory buyOrder = buyOrders[buyOrders.length - 1];
            if(buyOrder.validUntilBlock < block.number){
                buyOrders.pop();
                payable (buyOrder.issuer).transfer(buyOrder.price * buyOrder.quantity);
            } else if(sellOrder.price > buyOrder.price){
                break;
            } else
            {
                executeOrders(sellOrder, buyOrder, sellOrder.price);
                if(buyOrder.quantity == 0){
                    buyOrders.pop();
                }
            }
        }

        if(sellOrder.quantity > 0){
            addToSellOrders(sellOrder);
        }
    }


    function executeOrders(Order memory sellOrder, Order memory buyOrder, uint price) private {
        uint transferringQuantity = min(sellOrder.quantity, buyOrder.quantity);

        buyOrder.quantity -= transferringQuantity;
        liquidStocks[buyOrder.issuer] += transferringQuantity;

        sellOrder.quantity -= transferringQuantity;
        payable (sellOrder.issuer).transfer(transferringQuantity * price);
    }


    function min(uint v1, uint v2) internal pure returns (uint){
        return v1 < v2 ? v1 : v2;
    }


    function addToBuyOrders(Order memory order) private {
        uint i = 0;
        while(i < buyOrders.length || order.price > buyOrders[i].price){
            i++;
        }
        addElementToPosition(buyOrders, order, i);
    }


    function addToSellOrders(Order memory order) private {
        uint i = 0;
        while(i < sellOrders.length || order.price < sellOrders[i].price){
            i++;
        }
        addElementToPosition(sellOrders, order, i);
    }


    function addElementToPosition(Order[] storage orders, Order memory order, uint position) private {
        orders.push();
        for(uint i = orders.length;i>position;i--){
            orders[i] = orders[i-1];
        }
        orders[position] = order;
    }

    function getBuyOrders() external  view returns (Order[] memory){
        return buyOrders;
    }

    function getSellOrders() external  view returns (Order[] memory){
        return sellOrders;
    }

    //function freeOrder
}