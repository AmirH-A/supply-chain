// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  // <owner>
  address public owner;
  // <skuCount>
  uint256 public skuCount;
  // <items mapping>
  mapping (uint => Item) items;
  
  // <enum State: ForSale, Sold, Shipped, Received>
  enum State {ForSale, Sold, Shipped, Received}
  // <struct Item: name, sku, price, state, seller, and buyer>
  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }
  /* 
   * Events
   */

  // <LogForSale event: sku arg>
  event LogForSale(string _name, uint price);
  // <LogSold event: sku arg>
  event LogSold(uint sku);
  // <LogShipped event: sku arg>
  event LogShipped(uint sku);
  // <LogReceived event: sku arg>
  event LogReceived(uint sku);

  /* 
   * Modifiers
   */


  modifier isOwner () {
    require(msg.sender == owner);
    _;
  }
  // <modifier: isOwner

  modifier verifyCaller (address _address) { 
    // require (msg.sender == _address);
    require (msg.sender == _address); 
    _;
  }

  modifier paidEnough(uint _price) { 
    // require(msg.value >= _price); 
    require (msg.value >= _price);
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
    _;
  }

  modifier forSale(uint _sku) {
    require(items[_sku].state == State.ForSale);
    _;
  }

   modifier sold(uint _sku) {
    require(items[_sku].state == State.Sold);
    _;
  }

   modifier shipped(uint _sku) {
    require(items[_sku].state == State.Shipped);
    _;
  }

   modifier received(uint _sku) {
    require(items[_sku].state == State.Received);
    _;
  }


  constructor() public {
    // 1. Set the owner to the transaction sender
    owner = msg.sender;
    // 2. Initialize the sku count to 0. Question, is this necessary?
    //no, uint by default is equal to 0 , like address that by default is equal to 0x0
    //not related but for fun :)
  }

  function addItem(string memory _name, uint _price) public returns (bool) {
    // 1. Create a new item and put in array
    // 2. Increment the skuCount by one
    // 3. Emit the appropriate event
    // 4. return true
    items[skuCount] = Item(_name, skuCount, _price, State.ForSale, msg.sender, address(0));
    skuCount = skuCount + 1;
    emit LogForSale(_name, _price);
    return true;
  }


  function buyItem(uint sku) payable public
   forSale(sku) paidEnough(sku) checkValue(sku){
  
    items[sku].seller.transfer(items[sku].price);
    items[sku].buyer = msg.sender;
    items[sku].state = State.Sold;
    emit LogSold(sku);
  
  }


  function shipItem(uint sku) public sold(sku) verifyCaller(items[sku].seller){
    items[sku].state = State.Shipped;
    emit LogShipped(sku);

  }

 
  function receiveItem(uint sku) public shipped(sku) verifyCaller(items[sku].buyer){
    items[sku].state = State.Received;
    emit LogReceived(sku);
  }

 
   function fetchItem(uint _sku) public view 
     returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
   
     name = items[_sku].name; 
     sku = items[_sku].sku; 
     price = items[_sku].price; 
     state = uint(items[_sku].state); 
     seller = items[_sku].seller; 
     buyer = items[_sku].buyer; 
     return (name, sku, price, state, seller, buyer);
   } 
}
