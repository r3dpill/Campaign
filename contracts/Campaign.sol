pragma solidity ^0.4.24;

contract Campaign {
    
    //variables
    address public owner;
    uint public deadline;
    uint public goal;
    uint public fundsRaised;
    uint public fundsLeft;
    
    //struct
    struct FunderStruct {
        uint amountContributed;
        uint amountRefunded;
    }
    
    // FunderStruct[] public funderStructs;
    mapping (address => FunderStruct) public funderStructs;
    
    //logs
    event LogContribution(address sender, uint amount);
    event LogRefundSent(address funder, uint amount);
    event LogWithdrawal(address beneficiary, uint amount);
    
    //constructor function
    constructor (uint campaignDuration, uint campaignGoal)
        public
    {
        owner = msg.sender;
        deadline = block.number + campaignDuration;
        goal = campaignGoal;
    }
    
    function isSucess()
        public
        constant
        returns(bool isIndeed)
    {
        return(fundsRaised >= goal);   
    }
    
    function hasFailed()
        public
        constant
        returns(bool hasIndeed)
    {
        return(fundsRaised < goal && block.number > deadline);    
    }
    
    function contribute()
        public
        payable
        returns(bool success)
    {
        require(msg.value != 0);
        require(!hasFailed());
        require(!isSucess());
        
        fundsRaised += msg.value;
        fundsLeft += msg.value;
        funderStructs[msg.sender].amountContributed += msg.value;
        emit LogContribution(msg.sender, msg.value);
        return true;
    }
    
    
    function withdrawFunds()
        public
        returns(bool success)
    {
        require(msg.sender == owner);
        require(isSucess());
        uint amount = address(this).balance;
        fundsLeft = fundsRaised - amount;
        owner.transfer(amount);
        emit LogWithdrawal(msg.sender, amount);
        return true;
    }
    
    function requestRefund()
        public
        returns(bool success)
    {
        uint amountOwed = funderStructs[msg.sender].amountContributed - funderStructs[msg.sender].amountRefunded;
        require(amountOwed>0);
        require(hasFailed());
        // optimistic accounting
        funderStructs[msg.sender].amountRefunded += amountOwed;
        fundsLeft -= amountOwed;
        require(msg.sender.send(amountOwed));
        emit LogRefundSent(msg.sender, amountOwed);
        return true;
    }
}
