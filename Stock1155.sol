// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Stock is ERC1155, Ownable, ERC1155Burnable {

    mapping (address => uint256) public BuyerData;

    string public name;
    string public symbol;
    uint256 public cost = 0.05 ether;
    uint256 public total_supply = 1;
    address private _recipient;
    uint256 public _editionLimit = 1000;
    uint256 public _maxlimit = 100;

    constructor() ERC1155("https://token-cdn-domain/{id}.json") {
         name = "BlockTAK";
        symbol = "TAK"; 
        _recipient = owner();
        //string memory _inituri

    }

    function setURI(string memory newuri) 
    public 
    onlyOwner 
    {
        _setURI(newuri);  
    }

    function mint(uint256 id, uint256 amount)
        public
        payable 
    {
        require(id <= total_supply, "Exceed Supply");
        require(amount <= _editionLimit, "Exceed Limit");
        require(amount <= _maxlimit, "Exceed Limit");
        require(balanceOf(msg.sender, id) <= _maxlimit,"Cannot Buy More");
        require(msg.value >= cost * amount, "Insufficient Amount");
        _mint(msg.sender, id, amount, "");
        BuyerData[msg.sender] += amount;

    }


    function burn(address _from ,uint256 _id, uint256 _amount) public override onlyOwner {
        _burn(_from, _id, _amount);
    }

    //Transfer Amount to NFT721.
    function transferAmounttoNFT721(address ContractAdd)
        public 
        payable 
        onlyOwner
    {
        require(address(this).balance > 0, "Zero Balance");
        payable(ContractAdd).transfer(address(this).balance);
        
    }

    //Calculate Profit
    function calculateprofit(address YourAddres) 
        private  
        view 
        returns(uint256) {

        uint256 Profit = (BuyerData[YourAddres]*100 / _editionLimit);
        return Profit;
    }

    //SmartContract Balance. 
    function getBalance() 
        public 
        view 
        returns(uint) 
    {

        return address(this).balance;
    }


    //Owner 10% Profit.
    function OwnerProfit(address WithdrawAdd) 
        public 
        onlyOwner 
    {
        require(address(this).balance > 0, "Zero Balance");
        uint256 ownerprofit = (address(this).balance * 10/100);  
        payable(WithdrawAdd).transfer(address(this).balance - (address(this).balance - ownerprofit));
    }
    
    //User Withdraw Profit.
    function UserProfit(address WithdrawAdd) 
        public 
        {
            require(address(this).balance > 0, "Profit hasn't come yet.");
            uint256 userprofit = calculateprofit(WithdrawAdd);
            uint256 _userprofit = (address(this).balance * userprofit/100);
            payable(WithdrawAdd).transfer(address(this).balance - (address(this).balance - _userprofit));


    }

}
