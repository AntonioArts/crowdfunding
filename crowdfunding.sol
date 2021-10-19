// SPDX-Licence-Identifier: MIT

pragma solidity >=0.6.6 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    
    address public owner;
    address[] public funders;
    
    constructor() {
        owner = msg.sender;
    }
    
    mapping(address => uint256) public addressToAmmountFunded;
    
    function fund() public payable {
        uint256 minUsd = 5 * 10 ** 18;
        require(getConversionRate(msg.value) >= minUsd, "Not enough eth");
        addressToAmmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    function getVersion() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        return priceFeed.version();
    }
    
    function getPrice() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }
    
    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount / 1000000000000000000);
        return ethAmountInUsd;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function withdraw() public payable onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
        for (uint256 funderIdx = 0; funderIdx < funders.length; funderIdx++) {
            address funder = funders[funderIdx];
            addressToAmmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}

