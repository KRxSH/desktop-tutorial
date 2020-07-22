pragma solidity ^0.5.0;
contract Escrow {
    uint public contract_actv_time;
    uint public dispute_time;
    uint public amount;
    uint public escrow_fee;
    address payable public buyer;
    address payable public seller;
    address payable public escrow;
    bool public actv_seller = false;
    bool public actv_buyer = false;
    bool public contract_actv = false;
    bool public dispute_raised = false;
    bool public contract_settled = false;
    
    constructor (
        address payable _buyer, 
        address payable _seller, 
        address payable _escrow,
        uint _amount, 
        uint _escrow_fee,
        uint _dispute_time
        ) public {
            buyer = _buyer;
            seller = _seller;
            escrow = _escrow;
            amount = _amount;
            escrow_fee = _escrow_fee;
            dispute_time = _dispute_time;
        }
    
    function payment_by_buyer() public payable {
        require(
            msg.value >= (amount+escrow_fee) && 
            !contract_actv &&
            msg.sender == buyer
        );
        uint amount_paid = msg.value;
        uint amount_by_buyer = amount+escrow_fee;
        
        if (amount_by_buyer != amount_paid) {
            uint amount_to_return = amount_paid - amount_by_buyer;
            msg.sender.transfer(amount_to_return);
        }
        actv_buyer = true;
        
        if(actv_seller == true) {
            contract_actv_time  = now;
            contract_actv = true;
        }
    }
    
    function payment_by_seller() public payable {
        require(
            msg.value >= escrow_fee &&
            !contract_actv &&
            msg.sender == seller
        );
        uint amount_paid = msg.value;
        
        if (escrow_fee != amount_paid) {
            uint amount_to_return = amount_paid - escrow_fee;
            msg.sender.transfer(amount_to_return);
        }
        actv_seller = true;
        
        if(actv_buyer == true) {
            contract_actv_time  = now;
            contract_actv = true;
        }
    }
    
    function withdraw_by_buyer() public{
        require( 
            actv_buyer &&
            contract_actv == false && 
            msg.sender == buyer);
        actv_buyer = true;
        uint amount_by_buyer = amount+escrow_fee;
        buyer.transfer(amount_by_buyer);
    }
    
    function withdraw_by_seller() public{
        require( 
            actv_seller &&
            contract_actv == false && 
            msg.sender == buyer);
        actv_seller = true;
        buyer.transfer(escrow_fee);
    }
    
    function settle() public {
        require(msg.sender == buyer);
        buyer.transfer(escrow_fee);
        uint amount_to_seller = escrow_fee + amount;
        seller.transfer(amount_to_seller);
        contract_settled = true;
    }
    
    function force_settle() public {
        require(now>(dispute_time+contract_actv_time));
        buyer.transfer(escrow_fee);
        uint amount_to_seller = escrow_fee + amount;
        seller.transfer(amount_to_seller);
        contract_settled = true;
    }
    
    function raise_dispute() public {
        require(msg.sender == buyer);
        dispute_raised = true;
    }
    
    function pay_to_seller() public {
        require(msg.sender == escrow && dispute_raised == true);
        escrow.transfer(escrow_fee);
        uint amount_to_seller = escrow_fee + amount;
        seller.transfer(amount_to_seller);
        contract_settled = true;
    }
    
    function pay_to_buyer() public {
        require(msg.sender == escrow && dispute_raised == true);
        escrow.transfer(escrow_fee);
        uint amount_to_buyer = escrow_fee + amount;
        buyer.transfer(amount_to_buyer);
        contract_settled = true;
    }
}
