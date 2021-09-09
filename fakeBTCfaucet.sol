// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount) external returns (bool);

}

contract fakeBTCfaucet {

    // The underlying token of the Faucet
    IERC20 token;

    // The address of the faucet owner
    address owner;

    // Dripping time interval
    uint faucetDripInterval = 5;

    // For rate limiting
    mapping(address=>uint) nextRequestAt;

    // No.of tokens to send when requested
    uint faucetDripAmount = 100;

    // Sets the addresses of the Owner and the underlying token
    constructor () {
        token = IERC20(0x01936b2f62Fb0753343c59C52Ea40437173CF147);
        owner = msg.sender;
    }

    // Verifies whether the caller is the owner
    modifier onlyOwner{
        require(msg.sender == owner,"FaucetError: Caller not owner");
        _;
    }

    // Sends the amount of token to the caller.
    function send() external {
        require(token.balanceOf(address(this)) > 1,"FaucetError: Empty");
        require(nextRequestAt[msg.sender] < block.timestamp, "FaucetError: Try again later");

        // Next request from the address can be made only after 5 minutes
        nextRequestAt[msg.sender] = block.timestamp + (faucetDripInterval*1 minutes);

        token.transfer(msg.sender,faucetDripAmount * 10**token.decimals());
    }

    // Updates the underlying token address
     function setTokenAddress(address _tokenAddr) external onlyOwner {
       token = IERC20(_tokenAddr);
    }

    // Updates the drip rate
     function setFaucetDripAmount(uint _amount) external onlyOwner {
        faucetDripAmount = _amount;
    }

    // Updates the drip interval
     function setDripInterval(uint _interval) external onlyOwner {
        faucetDripInterval = _interval;
    }

     // Allows the owner to withdraw tokens from the contract.
     function withdrawTokens(address _receiver, uint256 _amount) external onlyOwner {
        require(token.balanceOf(address(this)) >= _amount,"FaucetError: Insufficient funds");
        token.transfer(_receiver,_amount);
    }
}
